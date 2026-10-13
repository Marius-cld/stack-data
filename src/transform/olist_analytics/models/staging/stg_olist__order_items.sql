with source as (
    select * from {{ source('olist_raw', 'order_items') }}
),

renamed as (
    select
        -- clés
        order_id,
        order_item_id::int as order_item_id,
        product_id,
        seller_id,

        -- dates
        shipping_limit_date::timestamp as shipping_limit_at,

        -- montants (BRL)
        price::numeric(10, 2) as item_price,
        freight_value::numeric(10, 2) as freight_value,
        price::numeric(10, 2) + freight_value::numeric(10, 2) as total_item_value
    from source
)

select * from renamed
