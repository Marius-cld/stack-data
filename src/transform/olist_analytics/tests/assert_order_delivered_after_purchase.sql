-- Une commande ne peut pas être livrée avant d'avoir été passée

select
    order_id,
    ordered_at,
    delivered_to_customer_at
from {{ ref('fct_orders') }}
where delivered_to_customer_at < ordered_at
