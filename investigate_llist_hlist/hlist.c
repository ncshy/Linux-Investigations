#include <linux/list.h>
#include <linux/init.h>
#include <linux/module.h>
#include <linux/mm.h>

MODULE_AUTHOR("Nishanth C");
MODULE_LICENSE("GPL");

struct my_struct {
        unsigned long data;
        struct hlist_node hlist;
};

HLIST_HEAD(head);

static int insert_elems(unsigned long data)
{
        struct my_struct *new = kmalloc(sizeof(struct my_struct), GFP_KERNEL);
        if (!new)
                return -1;
        new->data = data;
        INIT_HLIST_NODE(&new->hlist);

        hlist_add_head(&new->hlist, &head);
        pr_info("Successfully inserted %lu\n", data);

        return 0;
}

static inline void traverse_forward(void)
{
        struct hlist_node *hnode;
        hlist_for_each(hnode, &head) {
                struct my_struct *ms = hlist_entry(hnode, struct my_struct, hlist);
                pr_info("In element %lu\n", ms->data);
        }
}

static inline void delete_container_struct(void) {
        struct hlist_node *hnode;
        hlist_for_each(hnode, &head) {
                struct my_struct *ms = list_entry(hnode, struct my_struct, hlist);
                kfree(ms);
        }
}

static void call_main(void)
{
        int ret;
        ret = insert_elems(100);
        if (ret < 0)
                return;
        ret = insert_elems(200);
        if (ret < 0)
                return;
        ret = insert_elems(300);
        if (ret < 0)
                return;
       ret = insert_elems(400);
        if (ret < 0)
                return;

        traverse_forward();

        delete_container_struct();
}

static int __init load(void)
{
        pr_info("Inside __init load function\n");
        call_main();
        return 0;
}

static void __exit unload(void)
{
        pr_info("Inside __exit unload\n");
}

module_init(load);
module_exit(unload);
