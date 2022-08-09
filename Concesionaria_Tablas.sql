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

CREATE OR REPLACE VIEW VW_Cliente_Compro_BMW AS 
(
	SELECT nombre, apellido, modelo FROM Cliente
    WHERE marca LIKE "%BMW"
) ;

CREATE OR REPLACE VIEW VW_Cliente_Gasto_Mayor AS 
(
	SELECT nombre, apellido, dinero_gastado FROM Cliente 
    WHERE dinero_gastado > 500000 order by dinero_gastado desc 
) ;

CREATE OR REPLACE VIEW VW_Cliente_Auto_User_Ins AS (
	SELECT Cliente.nombre, Cliente.apellido, 
    Cliente.modelo, Autos.ID_user_ins, Cliente.oper_insert
	FROM Cliente 
	INNER JOIN Autos ON Autos.Marca=Cliente.Marca
) ;

ALTER TABLE Proveedor
ADD foreign key (id_A)	
REFERENCES Autos(id_A);

ALTER TABLE Proveedor_Vendedor
ADD foreign key (id_P)
REFERENCES Proveedor(id_P);

ALTER TABLE Proveedor_Vendedor
ADD foreign key (id_V)
REFERENCES Vendedor(id_V);