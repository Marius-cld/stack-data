with products as (
    select * from {{ ref('int_products_translated') }}
),

item_stats as (
    select
        product_id,
        count(*) as units_sold,
        round(avg(item_price), 2) as avg_price,
        sum(item_price) as total_revenue
    from {{ ref('stg_olist__order_items') }}
    group by 1
),

final as (
    select
        products.product_id,
        products.category_name,
        products.category_name_pt,
        products.photo_count,
        products.weight_g,
        products.length_cm,
        products.height_cm,
        products.width_cm,
        coalesce(item_stats.units_sold, 0) as units_sold,
        item_stats.avg_price,
        coalesce(item_stats.total_revenue, 0) as total_revenue
    from products
    left join item_stats on products.product_id = item_stats.product_id
)

select * from final
