with orders as (
    select * from {{ ref('int_orders_enriched') }}
),

geolocation as (
    select * from {{ ref('int_geolocation_aggregated') }}
),

-- un client a un customer_id par commande : on garde l'adresse de sa dernière commande
latest_address as (
    select distinct on (customer_unique_id)
        customer_unique_id,
        customer_zip_code_prefix as zip_code_prefix,
        customer_city,
        customer_state
    from orders
    order by customer_unique_id, ordered_at desc, order_id
),

customer_orders as (
    select
        customer_unique_id,
        count(*) as order_count,
        sum(total_paid) as lifetime_value,
        min(ordered_at) as first_order_at,
        max(ordered_at) as last_order_at,
        round(avg(review_score), 2) as avg_review_score
    from orders
    group by 1
),

final as (
    select
        customer_orders.customer_unique_id,
        latest_address.zip_code_prefix,
        latest_address.customer_city,
        latest_address.customer_state,
        geolocation.latitude,
        geolocation.longitude,
        customer_orders.order_count,
        customer_orders.lifetime_value,
        customer_orders.first_order_at,
        customer_orders.last_order_at,
        customer_orders.avg_review_score,
        case
            when customer_orders.order_count >= 3 then 'loyal'
            when customer_orders.order_count = 2 then 'repeat'
            else 'one_time'
        end as customer_segment
    from customer_orders
    inner join latest_address on customer_orders.customer_unique_id = latest_address.customer_unique_id
    left join geolocation on latest_address.zip_code_prefix = geolocation.zip_code_prefix
)

select * from final
