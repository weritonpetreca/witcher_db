/* =========================================================
   The Witcher DB – MODELO LÓGICO
   Tabelas: Cliente, Produto, Pedido, Item_Pedido
   Regras:
     •  PKs = brasões (identidade única)
     •  FKs = rotas comerciais
     •  Normalizado até 3NF
   ========================================================= */

-- 1. Criação do esquema
CREATE SCHEMA IF NOT EXISTS witcher_db;
SET search_path TO witcher_db;

-- 2. Tabela Cliente (habitantes)
CREATE TABLE cliente (
    cliente_id   SERIAL PRIMARY KEY,
    nome         VARCHAR(120)  NOT NULL,
    email        VARCHAR(120)  UNIQUE NOT NULL,
    cidade       VARCHAR(80),
    criado_em    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Tabela Produto (itens de contrato)
CREATE TABLE produto (
    produto_id   SERIAL PRIMARY KEY,
    nome         VARCHAR(120) NOT NULL,
    descricao    TEXT,
    preco_moedas NUMERIC(12,2) NOT NULL CHECK (preco_moedas >= 0)
);

-- 4. Tabela Pedido (contratos)
CREATE TABLE pedido (
    pedido_id     SERIAL PRIMARY KEY,
    cliente_id    INT NOT NULL,
    data_pedido   DATE NOT NULL DEFAULT CURRENT_DATE,
    valor_total   NUMERIC(14,2) NOT NULL DEFAULT 0,
    status        VARCHAR(30)  DEFAULT 'ABERTO',
    CONSTRAINT fk_pedido_cliente
      FOREIGN KEY (cliente_id)
      REFERENCES cliente (cliente_id)
      ON DELETE RESTRICT
      ON UPDATE CASCADE
);

-- 5. Tabela Item_Pedido (itens do contrato)
CREATE TABLE item_pedido (
    item_pedido_id SERIAL PRIMARY KEY,
    pedido_id      INT NOT NULL,
    produto_id     INT NOT NULL,
    quantidade     INT NOT NULL CHECK (quantidade > 0),
    preco_unitario NUMERIC(12,2) NOT NULL CHECK (preco_unitario >= 0),
    CONSTRAINT fk_item_pedido
      FOREIGN KEY (pedido_id)
      REFERENCES pedido (pedido_id)
      ON DELETE CASCADE,
    CONSTRAINT fk_item_produto
      FOREIGN KEY (produto_id)
      REFERENCES produto (produto_id)
      ON DELETE RESTRICT
);

-- 6. Trigger para manter regra de negócio: valor_total = soma(item)
CREATE OR REPLACE FUNCTION atualizar_valor_pedido() RETURNS TRIGGER AS $$
BEGIN
  UPDATE pedido
     SET valor_total =
       (SELECT COALESCE(SUM(quantidade * preco_unitario),0)
          FROM item_pedido
         WHERE pedido_id = NEW.pedido_id)
   WHERE pedido_id = NEW.pedido_id;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_item_pedido_aiu
AFTER INSERT OR UPDATE OR DELETE ON item_pedido
FOR EACH ROW EXECUTE FUNCTION atualizar_valor_pedido();