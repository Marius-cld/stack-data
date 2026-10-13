with items as (
    select * from {{ ref('stg_olist__order_items') }}
),

orders as (
    select * from {{ ref('int_orders_enriched') }}
),

final as (
    select
        -- clés : les attributs produit / vendeur / client sont dans les dimensions
        {{ dbt_utils.generate_surrogate_key(['items.order_id', 'items.order_item_id']) }} as order_item_pk,
        items.order_id,
        items.order_item_id,
        items.product_id,
        items.seller_id,
        orders.customer_unique_id,

        -- dates
        orders.ordered_at,
        items.shipping_limit_at,

        -- mesures (BRL)
        items.item_price,
        items.freight_value,
        items.total_item_value
    from items
    inner join orders on items.order_id = orders.order_id
)

select * from final
