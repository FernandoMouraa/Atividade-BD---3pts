-- Parte 2 

-- As 3 novas tabelas


CREATE TABLE Exames (
    id_exame INT AUTO_INCREMENT PRIMARY KEY,
    tipo_exame VARCHAR(100) NOT NULL,
    resultados VARCHAR(255),
    data_exame DATE NOT NULL
) ENGINE=InnoDB;

CREATE TABLE Agendamentos (
    id_agendamento INT AUTO_INCREMENT PRIMARY KEY,
    id_paciente INT NOT NULL,
    data_agendamento DATE NOT NULL,
    status VARCHAR(50) DEFAULT 'Pendente',
    FOREIGN KEY (id_paciente) REFERENCES Pacientes(id_paciente)
) ENGINE=InnoDB;

CREATE TABLE Funcionarios (
    id_funcionario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cargo VARCHAR(50),
    salario DECIMAL(10, 2)
) ENGINE=InnoDB;



-- Trigger que impede agendamento duplicado

DELIMITER $$

CREATE TRIGGER impedir_agendamento_duplicado
BEFORE INSERT ON Agendamentos
FOR EACH ROW
BEGIN
    DECLARE agendamento_existente INT;
    SELECT COUNT(*) INTO agendamento_existente
    FROM Agendamentos
    WHERE id_paciente = NEW.id_paciente AND data_agendamento = NEW.data_agendamento;

    IF agendamento_existente > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Já existe um agendamento para esse paciente nesta data.';
    END IF;
END $$

DELIMITER ;

-- Trigger Loga as alterações de salário

CREATE TABLE Log_Salarios (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_funcionario INT NOT NULL,
    salario_antigo DECIMAL(10, 2),
    salario_novo DECIMAL(10, 2),
    data_alteracao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_funcionario) REFERENCES Funcionarios(id_funcionario)
) ENGINE=InnoDB;

DELIMITER $$

CREATE TRIGGER log_alteracoes_salario
AFTER UPDATE ON Funcionarios
FOR EACH ROW
BEGIN
    IF OLD.salario <> NEW.salario THEN
        INSERT INTO Log_Salarios (id_funcionario, salario_antigo, salario_novo)
        VALUES (NEW.id_funcionario, OLD.salario, NEW.salario);
    END IF;
END $$

DELIMITER ;

-- Trigger Verifica a data de exames

DELIMITER $$

CREATE TRIGGER verificar_data_exame
BEFORE INSERT ON Exames
FOR EACH ROW
BEGIN
    IF NEW.data_exame > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A data do exame não pode ser no futuro.';
    END IF;
END $$

DELIMITER ;

-- Trigger Loga os exames removidos

CREATE TABLE Log_Exames_Removidos (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_exame INT,
    data_remocao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

DELIMITER $$

CREATE TRIGGER log_remocao_exame
AFTER DELETE ON Exames
FOR EACH ROW
BEGIN
    INSERT INTO Log_Exames_Removidos (id_exame)
    VALUES (OLD.id_exame);
END $$

DELIMITER ;

-- Trigger  Verifica o aumento excessivo de salário
DELIMITER $$

CREATE TRIGGER verificar_aumento_salario
BEFORE UPDATE ON Funcionarios
FOR EACH ROW
BEGIN
    IF NEW.salario > OLD.salario * 1.5 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Aumento salarial maior que 50% não permitido.';
    END IF;
END $$

DELIMITER ;



-- Procedure de Cadastrar Exame


DELIMITER $$

CREATE PROCEDURE cadastrar_exame (
    IN p_tipo_exame VARCHAR(100),
    IN p_resultados VARCHAR(255),
    IN p_data_exame DATE
)
BEGIN
    INSERT INTO Exames (tipo_exame, resultados, data_exame)
    VALUES (p_tipo_exame, p_resultados, p_data_exame);
END $$

DELIMITER ;

-- Teste de exame
CALL cadastrar_exame('Raio-X', 'Fratura no braço', '2024-09-10');


-- Procedure de Atualizar Salário do Funcionário


DELIMITER $$

CREATE PROCEDURE atualizar_salario_funcionario (
    IN p_id_funcionario INT,
    IN p_novo_salario DECIMAL(10, 2)
)
BEGIN
    UPDATE Funcionarios
    SET salario = p_novo_salario
    WHERE id_funcionario = p_id_funcionario;
END $$

DELIMITER ;

-- Teste de atualização de salario

CALL atualizar_salario_funcionario(2, 4500.00);


-- Procedure que Cadastra os Agendamentos

DELIMITER $$

CREATE PROCEDURE cadastrar_agendamento (
    IN p_id_paciente INT,
    IN p_data_agendamento DATE
)
BEGIN
    INSERT INTO Agendamentos (id_paciente, data_agendamento)
    VALUES (p_id_paciente, p_data_agendamento);
END $$

DELIMITER ;

-- Teste de Cadastramento de Agendamento

CALL cadastrar_agendamento(1, '2024-09-20');


-- Procedure para Remover Funcionário

DELIMITER $$

CREATE PROCEDURE remover_funcionario (
    IN p_id_funcionario INT
)
BEGIN
    DELETE FROM Funcionarios
    WHERE id_funcionario = p_id_funcionario;
END $$

DELIMITER ;

-- Teste de Remoção do Funcionário

CALL remover_funcionario(3);


-- Procedure que Busca Exames pelo Tipo

DELIMITER $$

CREATE PROCEDURE buscar_exames_por_tipo (
    IN p_tipo_exame VARCHAR(100)
)
BEGIN
    SELECT * FROM Exames
    WHERE tipo_exame = p_tipo_exame;
END $$

DELIMITER ;

-- Teste de Busca
CALL buscar_exames_por_tipo('Raio-X');