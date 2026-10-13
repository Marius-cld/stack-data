with source as (
    select * from {{ source('olist_raw', 'sellers') }}
),

renamed as (
    select
        -- clés
        seller_id,

        -- localisation (le code postal reste en texte pour garder les zéros de tête)
        seller_zip_code_prefix as zip_code_prefix,
        initcap(seller_city) as seller_city,
        upper(seller_state) as seller_state
    from source
)

select * from renamed
