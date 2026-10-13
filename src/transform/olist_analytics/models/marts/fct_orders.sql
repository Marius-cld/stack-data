with orders as (
    select * from {{ ref('int_orders_enriched') }}
),

final as (
    select
        -- clés
        order_id,
        customer_unique_id,

        -- attributs
        order_status,
        main_payment_type,
        customer_state,

        -- dates
        ordered_at,
        approved_at,
        delivered_to_carrier_at,
        delivered_to_customer_at,
        estimated_delivery_date,

        -- mesures
        item_count,
        items_price,
        freight_value,
        total_paid,
        payment_count,
        max_installments,
        delivery_days,
        delivery_vs_estimate_days,
        review_score,

        -- indicateurs
        order_status = 'delivered' as is_delivered,
        -- NULL tant que la commande n'est pas livrée
        delivery_vs_estimate_days <= 0 as is_delivered_on_time
    from orders
)

select * from final
