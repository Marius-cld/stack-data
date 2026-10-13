with orders as (
    select * from {{ ref('stg_olist__orders') }}
),

customers as (
    select * from {{ ref('stg_olist__customers') }}
),

payments as (
    select * from {{ ref('int_payments_aggregated') }}
),

items as (
    select
        order_id,
        count(*) as item_count,
        sum(item_price) as items_price,
        sum(freight_value) as freight_value
    from {{ ref('stg_olist__order_items') }}
    group by 1
),

-- une commande peut avoir plusieurs avis : on garde le plus récent
latest_reviews as (
    select distinct on (order_id)
        order_id,
        review_score
    from {{ ref('stg_olist__order_reviews') }}
    order by order_id, review_created_at desc, review_answered_at desc, review_id
),

enriched as (
    select
        orders.order_id,
        orders.customer_id,
        customers.customer_unique_id,
        customers.zip_code_prefix as customer_zip_code_prefix,
        customers.customer_city,
        customers.customer_state,

        orders.order_status,
        orders.ordered_at,
        orders.approved_at,
        orders.delivered_to_carrier_at,
        orders.delivered_to_customer_at,
        orders.estimated_delivery_date,

        -- date - date donne un nombre de jours entier en PostgreSQL
        orders.delivered_to_customer_at::date - orders.ordered_at::date as delivery_days,
        -- positif : livrée en retard par rapport à la date estimée
        orders.delivered_to_customer_at::date - orders.estimated_delivery_date as delivery_vs_estimate_days,

        -- certaines commandes (annulées, indisponibles) n'ont aucun article
        coalesce(items.item_count, 0) as item_count,
        coalesce(items.items_price, 0) as items_price,
        coalesce(items.freight_value, 0) as freight_value,

        payments.total_paid,
        payments.payment_count,
        payments.max_installments,
        payments.main_payment_type,

        latest_reviews.review_score
    from orders
    left join customers on orders.customer_id = customers.customer_id
    left join items on orders.order_id = items.order_id
    left join payments on orders.order_id = payments.order_id
    left join latest_reviews on orders.order_id = latest_reviews.order_id
)

select * from enriched
