CREATE SCHEMA CONCESIONARIA ;
USE CONCESIONARIA ;

CREATE TABLE Usuarios_UPD (
	ID_user_upd int Primary Key auto_increment,
    nombre VARCHAR(30),
    apellido VARCHAR(30)
);

CREATE TABLE Usuarios_INS (
	ID_user_ins int Primary Key auto_increment,
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
	anio date
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

ALTER TABLE Proveedor
ADD foreign key (id_A)	
REFERENCES Autos(id_A);

ALTER TABLE Proveedor_Vendedor
ADD foreign key (id_P)
REFERENCES Proveedor(id_P);

ALTER TABLE Proveedor_Vendedor
ADD foreign key (id_V)
REFERENCES Vendedor(id_V);