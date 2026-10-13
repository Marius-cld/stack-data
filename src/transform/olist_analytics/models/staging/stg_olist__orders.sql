with source as (
    select * from {{ source('olist_raw', 'orders') }}
),

renamed as (
    select
        -- clés
        order_id,
        customer_id,

        -- attributs
        order_status,

        -- dates (texte dans raw) castées en vrais timestamps
        order_purchase_timestamp::timestamp as ordered_at,
        order_approved_at::timestamp as approved_at,
        order_delivered_carrier_date::timestamp as delivered_to_carrier_at,
        order_delivered_customer_date::timestamp as delivered_to_customer_at,
        -- toujours à minuit dans la source : c'est une date, pas un horodatage
        order_estimated_delivery_date::date as estimated_delivery_date
    from source
)

select * from renamed
