                                                          * Bonus Question *

Problem statement : 

> Use a single SQL query to transform the product_hierarchy and product_prices datasets to the product_details table.


Solution : 

```
with cat as(
select id as  cat_id, level_text as category 
from balanced_tree.product_hierarchy 
where level_name='Category'
),
seg as (
select parent_id as cat_id,id as  seg_id, level_text as Segment 
from balanced_tree.product_hierarchy 
where level_name='Segment'
),
style as (
select parent_id as seg_id,id as  style_id, level_text as Style
from balanced_tree.product_hierarchy 
where level_name='Style'),
prod_final as(
 select c.cat_id as category_id,category as category_name,
 s.seg_id as segment_id,segment as segment_name,
 style_id,style as style_name
 from cat c join seg s 
 on c.cat_id=s.cat_id
 join style st on s.seg_id=st.seg_id
 )
select product_id, price ,
concat(style_name,' ',segment_name,' - ',category_name) as product_name,
category_id,segment_id,style_id,category_name,segment_name,style_name 
from prod_final pf join balanced_tree.product_prices pp
on pf.style_id=pp.id
```

Output := 

![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/d55fb55f-ca5e-4090-932a-c88372dbe807)

