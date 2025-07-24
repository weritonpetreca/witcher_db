SET search_path TO witcher_db;

/* Demo rápido: popular tabelas e validar regras */
BEGIN;

-- Clientes
INSERT INTO cliente (nome, email, cidade)
VALUES ('Geralt de Rívia', 'geralt@kaermorhen.wt', 'Kaer Morhen'),
       ('Yennefer de Vengerberg', 'yenn@aretuza.wt', 'Vengerberg');

-- Produtos
INSERT INTO produto (nome, descricao, preco_moedas) VALUES
  ('Contrato de Grifo', 'Eliminação de grifo nas montanhas', 350.00),
  ('Poção de Andorinha', 'Poção regenerativa para bruxos', 25.00);

-- Pedido (Geralt contrata Yennefer?)
INSERT INTO pedido (cliente_id) VALUES (1);  -- pedido_id = 1

-- Itens do pedido
INSERT INTO item_pedido (pedido_id, produto_id, quantidade, preco_unitario)
VALUES (1, 1, 1, 350.00),
       (1, 2, 4, 25.00);  -- 4 poções

-- Verificar valor_total calculado pela trigger
SELECT * FROM pedido WHERE pedido_id = 1;

COMMIT;

/* Consulta exemplo: listar pedidos com seus itens */
SELECT p.pedido_id,
       c.nome      AS cliente,
       p.valor_total,
       pr.nome     AS produto,
       ip.quantidade,
       ip.preco_unitario
FROM   pedido p
JOIN   cliente c      ON c.cliente_id = p.cliente_id
JOIN   item_pedido ip ON ip.pedido_id = p.pedido_id
JOIN   produto pr     ON pr.produto_id = ip.produto_id
ORDER BY p.pedido_id;