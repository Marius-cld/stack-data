with sellers as (
    select * from {{ ref('stg_olist__sellers') }}
),

geolocation as (
    select * from {{ ref('int_geolocation_aggregated') }}
),

seller_stats as (
    select
        seller_id,
        count(distinct order_id) as order_count,
        sum(item_price) as total_revenue,
        round(avg(freight_value), 2) as avg_freight
    from {{ ref('stg_olist__order_items') }}
    group by 1
),

final as (
    select
        sellers.seller_id,
        sellers.zip_code_prefix,
        sellers.seller_city,
        sellers.seller_state,
        geolocation.latitude,
        geolocation.longitude,
        coalesce(seller_stats.order_count, 0) as order_count,
        coalesce(seller_stats.total_revenue, 0) as total_revenue,
        seller_stats.avg_freight
    from sellers
    left join geolocation on sellers.zip_code_prefix = geolocation.zip_code_prefix
    left join seller_stats on sellers.seller_id = seller_stats.seller_id
)

select * from final
