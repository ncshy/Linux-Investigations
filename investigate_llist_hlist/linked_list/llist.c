#include <linux/list.h>
#include <linux/init.h>
#include <linux/module.h>
#include <linux/mm.h>

MODULE_AUTHOR("Nishanth C");
MODULE_LICENSE("GPL");

struct my_struct {
        unsigned long data;
        struct list_head list;
};
LIST_HEAD(head);

static int insert_elems(unsigned long data)
{
        struct my_struct *new = kmalloc(sizeof(struct my_struct), GFP_KERNEL);
        if (!new)
                return -1;
        new->data = data;
        INIT_LIST_HEAD(&new->list);

        list_add(&new->list, &head);
        pr_info("Successfully inserted %lu\n", data);

        return 0;
}
static inline void traverse_forward(void)
{
        struct list_head *mstr;
        list_for_each(mstr, &head) {
                struct my_struct *ms = list_entry(mstr, struct my_struct, list);
                pr_info("In element %lu\n", ms->data);
        }
}

static inline void traverse_backward(void)
{
        struct list_head *mstr;
        list_for_each_prev(mstr, &head) {
                struct my_struct *ms = list_entry(mstr, struct my_struct, list);
                pr_info("In element %lu\n", ms->data);
        }
}

static inline void delete_container_struct(void) {
        struct list_head *mstr;
        struct list_head *nptr;
        list_for_each_safe(mstr, nptr, &head) {
		list_del(mstr);
                struct my_struct *ms = list_entry(mstr, struct my_struct, list);
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
        traverse_backward();
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

