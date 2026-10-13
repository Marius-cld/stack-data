with source as (
    select * from {{ source('olist_raw', 'order_payments') }}
),

renamed as (
    select
        -- clés
        order_id,
        payment_sequential::int as payment_sequential,

        -- attributs : 'not_defined' est un moyen de paiement inconnu
        nullif(lower(payment_type), 'not_defined') as payment_type,
        payment_installments::int as installment_count,

        -- montants (BRL)
        payment_value::numeric(10, 2) as payment_value
    from source
)

select * from renamed
