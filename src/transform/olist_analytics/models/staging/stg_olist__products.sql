with source as (
    select * from {{ source('olist_raw', 'products') }}
),

renamed as (
    select
        -- clés
        product_id,

        -- attributs (les colonnes *_lenght de la source sont mal orthographiées)
        product_category_name as category_name_pt,
        product_name_lenght::int as product_name_length,
        product_description_lenght::int as product_description_length,
        product_photos_qty::int as photo_count,

        -- dimensions
        product_weight_g::int as weight_g,
        product_length_cm::int as length_cm,
        product_height_cm::int as height_cm,
        product_width_cm::int as width_cm
    from source
)

select * from renamed
