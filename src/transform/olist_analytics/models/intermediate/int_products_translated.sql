with products as (
    select * from {{ ref('stg_olist__products') }}
),

category_translation as (
    select * from {{ ref('stg_olist__product_category_name_translation') }}
),

translated as (
    select
        products.product_id,
        -- 2 catégories n'ont pas de traduction (on garde le nom portugais), 610 produits n'en ont pas
        coalesce(category_translation.category_name_en, products.category_name_pt, 'unknown') as category_name,
        products.category_name_pt,
        products.product_name_length,
        products.product_description_length,
        products.photo_count,
        products.weight_g,
        products.length_cm,
        products.height_cm,
        products.width_cm
    from products
    left join category_translation
        on products.category_name_pt = category_translation.category_name_pt
)

select * from translated
