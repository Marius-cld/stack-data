with source as (
    select * from {{ source('olist_raw', 'customers') }}
),

renamed as (
    select
        -- clés
        customer_id,
        customer_unique_id,

        -- localisation (le code postal reste en texte pour garder les zéros de tête)
        customer_zip_code_prefix as zip_code_prefix,
        initcap(customer_city) as customer_city,
        upper(customer_state) as customer_state
    from source
)

select * from renamed
