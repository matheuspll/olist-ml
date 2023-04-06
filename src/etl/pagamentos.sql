
-- - [ x ]  % de formas de pagamentos
-- - [ ]  Quantidade média de parcelas (quando cartão)


WITH tb_join AS (
    SELECT pag.*,
           item.idVendedor
        
    FROM pedido AS ped

    LEFT JOIN pagamento_pedido AS pag
    ON ped.idPedido = pag.idPedido

    LEFT JOIN item_pedido AS item
    ON ped.idPedido = item.idPedido

    WHERE ped.dtPedido < '2018-01-01'
    AND ped.dtPedido >= strftime('%Y-%m-%d', '2018-01-01', '-6 months')
    AND item.idVendedor IS NOT NULL
),

tb_group AS (
    SELECT idVendedor,
        descTipoPagamento,
        count(distinct idPedido) AS qtdePedidoMeioPagamento, -- qtde Pedido vendedor para cada meio de pagamento
        sum(vlPagamento) AS vlPedidoMeioPagamento -- receita total para cada meio de pagamento realizado pelo vendedor 

    FROM tb_join
    GROUP BY idVendedor, descTipoPagamento
    ORDER BY idVendedor, descTipoPagamento
)

-- [ x ] exibindo os valores de cada vendeodr em uma única linha (qtdePagamentos, valorTOTPagamento, ProporçãoPedidos, PorcentagemPagamentoVendedor)
SELECT
    idVendedor,

    -- quantidade total de cada tipo de pagamento pra cada vendedor
    sum(case when descTipoPagamento='boleto' then qtdePedidoMeioPagamento else 0 end) as qtde_boleto_pedido,
    sum(case when descTipoPagamento='credit_card' then qtdePedidoMeioPagamento else 0 end) as qtde_credit_card_pedido,
    sum(case when descTipoPagamento='voucher' then qtdePedidoMeioPagamento else 0 end) as qtde_voucher_pedido,
    sum(case when descTipoPagamento='debit_card' then qtdePedidoMeioPagamento else 0 end) as qtde_debit_card_pedido,

    -- receita total de cada meio de pagamento para cada vendedor
    sum(case when descTipoPagamento='boleto' then vlPedidoMeioPagamento else 0 end) as valor_boleto_pedido,
    sum(case when descTipoPagamento='credit_card' then vlPedidoMeioPagamento else 0 end) as valor_credit_card_pedido,
    sum(case when descTipoPagamento='voucher' then vlPedidoMeioPagamento else 0 end) as valor_voucher_pedido,
    sum(case when descTipoPagamento='debit_card' then vlPedidoMeioPagamento else 0 end) as valor_debit_card_pedido,

    -- porcentagem de pedidos pagos por boleto em relação ao total de pedidos realizados. Se a proporção resultar em 0, isso indica que nenhum pedido foi pago por boleto, enquanto uma proporção de 1 indica que todos os pedidos foram pagos por boleto.
    sum(case when descTipoPagamento='boleto' then qtdePedidoMeioPagamento else 0 end) / sum(qtdePedidoMeioPagamento) as pct_qtd_boleto_pedido,
    sum(case when descTipoPagamento='credit_card' then qtdePedidoMeioPagamento else 0 end) / sum(qtdePedidoMeioPagamento) as pct_qtd_credit_card_pedido,
    sum(case when descTipoPagamento='voucher' then qtdePedidoMeioPagamento else 0 end) / sum(qtdePedidoMeioPagamento) as pct_qtd_voucher_pedido,
    sum(case when descTipoPagamento='debit_card' then qtdePedidoMeioPagamento else 0 end) / sum(qtdePedidoMeioPagamento) as pct_qtd_debit_card_pedido,

    -- para descobrir o percental, basta dividir o TOTAL DE CADA MEIO DE PAGAMENTO desse vendedor pela RECEITA TOTAL de todos os meios
    sum(case when descTipoPagamento='boleto' then vlPedidoMeioPagamento else 0 end) / sum(vlPedidoMeioPagamento) as pct_valor_boleto_pedido,
    sum(case when descTipoPagamento='credit_card' then vlPedidoMeioPagamento else 0 end) / sum(vlPedidoMeioPagamento) as pct_valor_credit_card_pedido,
    sum(case when descTipoPagamento='voucher' then vlPedidoMeioPagamento else 0 end) / sum(vlPedidoMeioPagamento) as pct_valor_voucher_pedido,
    sum(case when descTipoPagamento='debit_card' then vlPedidoMeioPagamento else 0 end) / sum(vlPedidoMeioPagamento) as pct_valor_debit_card_pedido


FROM tb_group

GROUP BY 1
