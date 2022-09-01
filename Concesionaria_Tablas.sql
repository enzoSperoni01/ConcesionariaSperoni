CREATE SCHEMA CONCESIONARIA ;
USE CONCESIONARIA ;

CREATE TABLE Usuarios (
	ID_user int Primary Key auto_increment,
    nombre VARCHAR(30),
    apellido VARCHAR(30)
);

CREATE TABLE Marca (
	id_marca int PRIMARY KEY auto_increment,
    descripcion VARCHAR(50)
);

CREATE TABLE Modelo (
	id_modelo int PRIMARY KEY auto_increment,
    descripcion VARCHAR(50),
	anio int
);

CREATE TABLE Autos (
	id_A int PRIMARY KEY auto_increment,
    marca VARCHAR(50),
    modelo VARCHAR(50),
    id_marca int,
    id_modelo int,
    ID_user_upd int,
    ID_user_ins int,
    oper_insert datetime not null,
    oper_update datetime not null
);

CREATE TABLE Proveedor (
	id_P int PRIMARY KEY auto_increment,
    cuit VARCHAR(25),
    nombre VARCHAR(50),
    id_A int,
    ID_user_upd int,
    ID_user_ins int,
    oper_insert datetime not null,
    oper_update datetime not null
);

CREATE TABLE Vendedor (
	id_V int PRIMARY KEY auto_increment,
    nombre VARCHAR(30),
    apellido VARCHAR(30),
    ID_user_upd int,
    ID_user_ins int,
    oper_insert datetime not null,
    oper_update datetime not null
);

CREATE TABLE Cliente (
	id_C int PRIMARY KEY auto_increment,
    nombre VARCHAR(30),
    apellido VARCHAR(30),
    modelo VARCHAR(30),
    marca VARCHAR(30),
    dinero_gastado int,
    ID_user_upd int,
    ID_user_ins int,
    oper_insert datetime not null,
    oper_update datetime not null
);

CREATE TABLE Proveedor_Vendedor(
	id int PRIMARY KEY auto_increment,
    id_P int,
    id_V int,
    ID_user_upd int,
    ID_user_ins int,
    oper_insert datetime not null,
    oper_update datetime not null
);

-- Para saber quienes adquirieron un Modelo que sea BMW
CREATE OR REPLACE VIEW VW_Cliente_Compro_BMW AS 
(
	SELECT nombre, apellido, modelo FROM Cliente
    WHERE marca LIKE "%BMW"
) ;

-- Quienes realizaron un gasto mayor a $500.000
CREATE OR REPLACE VIEW VW_Cliente_Gasto_Mayor AS 
(
	SELECT nombre, apellido, dinero_gastado FROM Cliente 
    WHERE dinero_gastado > 500000 order by dinero_gastado desc 
) ;

-- Para saber que ID_User fue el que realizo un Insert, con que datos, con fecha y hora
CREATE OR REPLACE VIEW VW_Cliente_Auto_User_Ins AS (
	SELECT Cliente.nombre, Cliente.apellido, 
    Cliente.modelo, Autos.ID_user_ins, Cliente.oper_insert
	FROM Cliente 
	INNER JOIN Autos ON Autos.Marca=Cliente.Marca
) ;


-- Datos del cliente (Nombre y Apellido - Marca y Modelo)
delimiter //
create function fn_datos_cliente ( p_id_cliente int )
returns varchar(250)
deterministic
begin
	declare modelo_auto_cliente varchar(250) ;
    set modelo_auto_cliente = (
		SELECT concat(nombre, ' ', apellido, ' - ', marca, ' - ', modelo) 
		FROM Cliente 
        WHERE id_C = p_id_cliente
	) ;
    return modelo_auto_cliente ;
end //
delimiter ;


-- Sacar el IVA de la compra del Cliente
delimiter //
create function fn_gasto_cliente_IVA ( p_id_cliente int )
returns varchar(250)
deterministic
begin 
	declare suma_iva varchar(250) ;
    set suma_iva = (
		SELECT concat(
					nombre, ' ', apellido, ' - ', 
					modelo, ' - ', marca,
                    ' - IVA: ', (dinero_gastado * 0.21))
        FROM Cliente
        WHERE id_C = p_id_cliente
    ) ;
    return suma_iva ;
end //
delimiter ;

-- Ordenar las tablas por el tipo de columna que usuario desee, y si es Ascendente o Descendente
delimiter //
create procedure sp_order_tabla ( INOUT p_Order varchar(35), INOUT p_Asc_Desc varchar(35) )
begin
	set @var_1 = concat('SELECT * FROM Cliente U ORDER BY ', p_Order, ' ', p_Asc_Desc) ;
    prepare param_stmt from @var_1 ;
    execute param_stmt ;
    deallocate prepare param_stmt ;
end //
delimiter ;
set @p_Order = 'marca';
set @p_Asc_Desc = 'DESC';

call sp_order_tabla(@p_Order, @p_Asc_Desc);

-- SP: Para insertar datos en la tabla de "Clientes"
delimiter //
create procedure sp_insert_cliente ( INOUT p_nombre varchar(50),
									 INOUT p_apellido varchar(50),
                                     INOUT p_modelo varchar(50),
                                     INOUT p_marca varchar(50),
                                     INOUT p_dinero int,
                                     INOUT p_oper_insert varchar(50),
                                     INOUT p_oper_update varchar(50) )
begin
	insert into Cliente (
		nombre, 
        apellido, 
        modelo, 
        marca, 
        dinero_gastado, 
        oper_insert, 
        oper_update) 
	values(
		p_nombre, 
        p_apellido, 
        p_modelo, 
        p_marca, 
        p_dinero, 
        p_oper_insert, 
        p_oper_update
	);
end //
delimiter ;


-- Trigger AFTER = Muestre el ID del nuevo Cliente que se añadio
CREATE TABLE LOG_AUDIT_CLIENTES
(
	ID_log INT AUTO_INCREMENT,
	nombre_de_accion VARCHAR (10),
	nombre_tabla VARCHAR (50),
    nuevo_campo VARCHAR(3200),
	usuario VARCHAR (100),
	fecha_upd_ins_del DATE,
	PRIMARY KEY (ID_log)
) ;

DROP TRIGGER TRG_AFTER_INS_CLIENTES;
DELIMITER // 
CREATE TRIGGER TRG_AFTER_INS_CLIENTES 
AFTER INSERT ON Cliente FOR EACH ROW 
BEGIN 
	INSERT INTO LOG_AUDIT_CLIENTES (nombre_de_accion, nombre_tabla, nuevo_campo, usuario, fecha_upd_ins_del)
	VALUES ('INSERT','CLIENTE', NEW.id_C, CURRENT_USER(), NOW());
END //

-- Auditoria en BEFORE para Clientes = Nombres
CREATE TABLE LOG_AUDIT_UPD_CLIENTE
(
	ID_log INT AUTO_INCREMENT,
	nombre_de_accion VARCHAR (10),
	nombre_tabla VARCHAR (50),
	campo_anterior VARCHAR (3200),
	campo_nuevo VARCHAR (3200),
	usuario VARCHAR (100),
	fecha_upd_ins_del DATE,
	PRIMARY KEY (ID_log)
) ;

DROP TRIGGER TRG_BEFORE_UPD_CLIENTES;
DELIMITER // 
CREATE TRIGGER TRG_BEFORE_UPD_CLIENTES
BEFORE UPDATE ON Cliente FOR EACH ROW 
BEGIN
	INSERT INTO LOG_AUDIT_UPD_CLIENTE (nombre_de_accion, nombre_tabla, campo_anterior, campo_nuevo, usuario, fecha_upd_ins_del)
	VALUES ('UPDATE','CLIENTE', OLD.nombre, NEW.nombre, CURRENT_USER(),NOW());
END //

UPDATE Cliente SET nombre = 'Pablo' WHERE id_C = 2;

USE mysql;
CREATE USER 'reader@localhost'; -- Usuario de solo lecturas
CREATE USER 'total_user@localhost'; -- Usuario de Lectura, Insercion y Modificacion de datos

-- El usuario 'reader@localhost' podra solo hacer consultas de SELECT en la tabla Cliente
GRANT SELECT ON concesionaria.cliente TO 'reader@localhost';

-- El usuario 'total_user@localhost' podra hacer consultas SELECT, realizar INSERT y UPDATE de datos
GRANT SELECT, INSERT, UPDATE ON concesionaria.cliente TO 'total_user@localhost';

use mysql;
-- Revisar los permisos del usuario en cuestion
show grants for 'total_user@localhost';


-- Desafio de Clase 20
SELECT @@autocommit ;
SET AUTOCOMMIT = 1;
SET AUTOCOMMIT = 0;

start transaction;
delete from cliente where id_C = 37;
delete from cliente where id_C = 14;
rollback;
commit;

start transaction;
insert into Marca(descripcion) values('Alpha Romeo');
insert into Marca(descripcion) values('Audi');
insert into Marca(descripcion) values('Jeep');
insert into Marca(descripcion) values('Kia');
savepoint group_brand1;
insert into Marca(descripcion) values('Lexus');
insert into Marca(descripcion) values('Mazda');
insert into Marca(descripcion) values('Peugeot');
insert into Marca(descripcion) values('Seat');
savepoint group_brand2;

-- release savepoint group_brand1;

ALTER TABLE Proveedor
ADD foreign key (id_A)	
REFERENCES Autos(id_A);

ALTER TABLE Proveedor_Vendedor
ADD foreign key (id_P)
REFERENCES Proveedor(id_P);

ALTER TABLE Proveedor_Vendedor
ADD foreign key (id_V)
REFERENCES Vendedor(id_V);