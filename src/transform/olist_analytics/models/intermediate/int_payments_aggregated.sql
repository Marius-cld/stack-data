with payments as (
    select * from {{ ref('stg_olist__order_payments') }}
),

aggregated as (
    select
        order_id,
        sum(payment_value) as total_paid,
        count(*) as payment_count,
        max(installment_count) as max_installments,
        -- moyen de paiement principal : celui de la plus grosse ligne de paiement
        (array_agg(payment_type order by payment_value desc, payment_sequential))[1] as main_payment_type
    from payments
    group by 1
)

select * from aggregated
