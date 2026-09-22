## Difference between Linked list and Hash bucket list in Linux kernel

We will be exploring what is the main difference between a linked list and a hash bucket list in the Linux Kernel. <br>
A *linked list* is a well known data structure that holds a list of elements, but which can dynamically grow and shrink. <br>
A *hash bucket list* is used to handle collisions in a hash table. When a hash function runs on a key, it converges onto a specific hash bucket. A list is used here to track all the data points that landed on a specific bucket. <br>

We have 2 programs, both of which are implemented as Linux kernel modules and which were tested on Linux Kernel 6.1.138 <br>

### Linked list
The first program, named **llist.c** adds 4 elements onto a linked list, prints out these elements in forward (traverse\_forward()) and reverse(traverse\_backward()) directions. Finally we free the memory allocated by the module. <br>

Some important functions and macros are shown below: <br>

*INIT\_LIST\_HEAD* sets the newly created *list\_head* element to point to itself initially. <br>
```
static inline void INIT_LIST_HEAD(struct list_head *list)
{
        WRITE_ONCE(list->next, list);
        WRITE_ONCE(list->prev, list);
}
```
*list\_add()* adds an element between the head of the list, and the first element. The newly added element then becomes the first element in the list. <br>
```
/* Insert between 2 existing entries */
static inline void list_add(struct list_head *new, struct list_head *head)
{
        __list_add(new, head, head->next);
}
```
The below 3 macros are used to traverse the list. As can be seen in *list\_for\_each()*, the list moves forward through the *pos=pos-\>next* statement, and stops when it circles back and reaches the head again. <br>

*list\_entry()* is used to obtain the parent structure in which the *list\_head* element is embedded. <br>

*list\_for\_each\_prev()* is used for backward traversal. It starts at the last element *(head)-\>prev*, and moves backward through *pos=pos-\>prev* and stops when it circles back and hits the head element again. <br>

It should be obvious from this that the Linux Kernel linked list is a circular linked list implementation. <br>
```
#define list_for_each(pos, head) \
        for (pos = (head)->next; !list_is_head(pos, (head)); pos = pos->next)

#define list_entry(ptr, type, member) \
        container_of(ptr, type, member)

#define list_for_each_prev(pos, head) \
        for (pos = (head)->prev; !list_is_head(pos, (head)); pos = pos->prev)
```
The output for the linked list execution is shown below, the items are always added at the head, which is why when traversing forward the first element is 400, and the last element is 100. <br>
```
Sep 22 00:21:46 osboxes kernel: Inside __init load function
Sep 22 00:21:46 osboxes kernel: Successfully inserted 100
Sep 22 00:21:46 osboxes kernel: Successfully inserted 200
Sep 22 00:21:46 osboxes kernel: Successfully inserted 300
Sep 22 00:21:46 osboxes kernel: Successfully inserted 400
Sep 22 00:21:46 osboxes kernel: In element 400
Sep 22 00:21:46 osboxes kernel: In element 300
Sep 22 00:21:46 osboxes kernel: In element 200
Sep 22 00:21:46 osboxes kernel: In element 100
Sep 22 00:21:46 osboxes kernel: In element 100
Sep 22 00:21:46 osboxes kernel: In element 200
Sep 22 00:21:46 osboxes kernel: In element 300
Sep 22 00:21:46 osboxes kernel: In element 400
Sep 22 00:21:46 osboxes kernel: Inside __exit unload
```

### Hash bucket list

The main difference between a linked list and a hash bucket list, is that the head element only contains a next pointer. Therefore, it is not a circular list implementation. Now, the reason I have read in some places is that it's used to **reduce the memory footprint**, as the *hlist\_node* element avoids 8B of storage as it does not need a 'prev' pointer.

The hlist program has the same structure as the linked list program, except the embedded list element is of type *'struct hlist\_node'* and the head element is of type *'struct hlist\_head'*. The *hlist\_head* is a placeholder element that contains only a pointer to the first element of the hash bucket list. A hash table itself, is simply an array of these hlist\_head elements, and the hash function is used to converge to one of these buckets. <br>

The program logic in **hlist.c** is similar to the Linked list program, but does not include reverse traversal, as that is not possible with hash bucket lists. <br>
The 4 elements are once again added to the head of the hash bucket list, and are therefore printed in reverse order, as shown in the output below: <br>
```
Sep 22 00:22:51 osboxes kernel: Inside __init load function
Sep 22 00:22:51 osboxes kernel: Successfully inserted 100
Sep 22 00:22:51 osboxes kernel: Successfully inserted 200
Sep 22 00:22:51 osboxes kernel: Successfully inserted 300
Sep 22 00:22:51 osboxes kernel: Successfully inserted 400
Sep 22 00:22:51 osboxes kernel: In element 400
Sep 22 00:22:51 osboxes kernel: In element 300
Sep 22 00:22:51 osboxes kernel: In element 200
Sep 22 00:22:51 osboxes kernel: In element 100
Sep 22 00:22:51 osboxes kernel: Inside __exit unload
```

Below are some interesting macros and functions: <br>

*HLIST\_HEAD()* is used to initialize and create the *hlist\_head* element.
```
#define HLIST_HEAD(name) struct hlist_head name = {  .first = NULL }
```

*INIT\_HLIST\_NODE()*, sets the newly created node's elements to NULL.
```
static inline void INIT_HLIST_NODE(struct hlist_node *h)
{
        h->next = NULL;
        h->pprev = NULL;
}
```

*hlist\_add\_head()* adds elements to the head of the list. <br>
```
static inline void hlist_add_head(struct hlist_node *n, struct hlist_head *h)
{
        struct hlist_node *first = h->first;
        WRITE_ONCE(n->next, first);
        if (first)
                WRITE_ONCE(first->pprev, &n->next);
        WRITE_ONCE(h->first, n);
        WRITE_ONCE(n->pprev, &h->first);
}
```
The below 2 macros are used to traverse the hash bucket list. <br>
*hlist\_for\_each()*, starts at the first element ((head)-\>first) and moves forward (pos=pos-\>next) until it reaches NULL, i.e, after the last element. <br>
*hlist\_entry()* is same as *list\_entry()*, in that it is used to obtain the parent structure where the *hlist\_node* element is embededd. <br>
```
#define hlist_for_each(pos, head) \
        for (pos = (head)->first; pos ; pos = pos->next)

#define hlist_entry(ptr, type, member) container_of(ptr,type,member)
```

