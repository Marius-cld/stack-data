with source as (
    select * from {{ source('olist_raw', 'order_reviews') }}
),

renamed as (
    select
        -- clés : un même review_id peut porter sur plusieurs commandes
        review_id,
        order_id,

        -- attributs
        review_score::int as review_score,
        review_comment_title as comment_title,
        review_comment_message as comment_message,

        -- dates
        review_creation_date::timestamp as review_created_at,
        review_answer_timestamp::timestamp as review_answered_at
    from source
)

select * from renamed
