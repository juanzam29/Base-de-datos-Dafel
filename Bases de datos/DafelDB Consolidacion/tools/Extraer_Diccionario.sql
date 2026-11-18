USE [DafelDB];
GO

SET NOCOUNT ON;
GO

-- 1. Tablas y descripciones funcionales.
SELECT s.name esquema,t.name tabla,CONVERT(NVARCHAR(4000),ep.value) descripcion,
       (SELECT COUNT(*) FROM sys.columns c WHERE c.object_id=t.object_id) columnas,
       (SELECT SUM(p.rows) FROM sys.partitions p WHERE p.object_id=t.object_id AND p.index_id IN(0,1)) filas_aproximadas
FROM sys.tables t
JOIN sys.schemas s ON s.schema_id=t.schema_id
LEFT JOIN sys.extended_properties ep
  ON ep.class=1 AND ep.major_id=t.object_id AND ep.minor_id=0 AND ep.name=N'MS_Description'
WHERE t.is_ms_shipped=0
ORDER BY s.name,t.name;

-- 2. Atributos, tipos, nulabilidad, identidad, valores predeterminados y descripción.
SELECT s.name esquema,t.name tabla,c.column_id orden,c.name atributo,
       ty.name tipo,c.max_length,c.precision,c.scale,c.is_nullable,c.is_identity,
       dc.definition valor_predeterminado,cc.definition expresion_calculada,
       CONVERT(NVARCHAR(4000),ep.value) descripcion
FROM sys.tables t
JOIN sys.schemas s ON s.schema_id=t.schema_id
JOIN sys.columns c ON c.object_id=t.object_id
JOIN sys.types ty ON ty.user_type_id=c.user_type_id
LEFT JOIN sys.default_constraints dc ON dc.object_id=c.default_object_id
LEFT JOIN sys.computed_columns cc ON cc.object_id=c.object_id AND cc.column_id=c.column_id
LEFT JOIN sys.extended_properties ep
  ON ep.class=1 AND ep.major_id=t.object_id AND ep.minor_id=c.column_id AND ep.name=N'MS_Description'
WHERE t.is_ms_shipped=0
ORDER BY s.name,t.name,c.column_id;

-- 3. Claves primarias y únicas.
SELECT OBJECT_SCHEMA_NAME(k.parent_object_id) esquema,
       OBJECT_NAME(k.parent_object_id) tabla,k.name restriccion,k.type_desc,
       STRING_AGG(CONVERT(NVARCHAR(MAX),QUOTENAME(c.name)),N', ')
         WITHIN GROUP(ORDER BY ic.key_ordinal) columnas
FROM sys.key_constraints k
JOIN sys.index_columns ic
  ON ic.object_id=k.parent_object_id AND ic.index_id=k.unique_index_id AND ic.key_ordinal>0
JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id
GROUP BY k.parent_object_id,k.name,k.type_desc
ORDER BY esquema,tabla,restriccion;

-- 4. Relaciones y acciones referenciales.
SELECT fk.name relacion,
       OBJECT_SCHEMA_NAME(fk.parent_object_id) esquema_hija,
       OBJECT_NAME(fk.parent_object_id) tabla_hija,pc.name columna_hija,
       OBJECT_SCHEMA_NAME(fk.referenced_object_id) esquema_padre,
       OBJECT_NAME(fk.referenced_object_id) tabla_padre,rc.name columna_padre,
       pc.is_nullable relacion_opcional,
       fk.update_referential_action_desc al_actualizar,
       fk.delete_referential_action_desc al_eliminar,
       fk.is_disabled,fk.is_not_trusted
FROM sys.foreign_keys fk
JOIN sys.foreign_key_columns fkc ON fkc.constraint_object_id=fk.object_id
JOIN sys.columns pc ON pc.object_id=fkc.parent_object_id AND pc.column_id=fkc.parent_column_id
JOIN sys.columns rc ON rc.object_id=fkc.referenced_object_id AND rc.column_id=fkc.referenced_column_id
ORDER BY tabla_hija,relacion,fkc.constraint_column_id;

-- 5. Dominios CHECK.
SELECT OBJECT_SCHEMA_NAME(parent_object_id) esquema,
       OBJECT_NAME(parent_object_id) tabla,name restriccion,definition,
       is_disabled,is_not_trusted
FROM sys.check_constraints
ORDER BY esquema,tabla,name;

-- 6. Índices explícitos.
SELECT s.name esquema,t.name tabla,i.name indice,i.type_desc,i.is_unique,
       i.is_primary_key,i.is_unique_constraint,i.filter_definition,
       c.name columna,ic.key_ordinal,ic.is_descending_key,ic.is_included_column
FROM sys.tables t
JOIN sys.schemas s ON s.schema_id=t.schema_id
JOIN sys.indexes i ON i.object_id=t.object_id
JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id
JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id
WHERE t.is_ms_shipped=0 AND i.index_id>0
ORDER BY esquema,tabla,indice,ic.is_included_column,ic.key_ordinal,ic.index_column_id;

-- 7. Vistas, procedimientos y triggers.
SELECT s.name esquema,o.name objeto,o.type_desc,m.definition
FROM sys.objects o
JOIN sys.schemas s ON s.schema_id=o.schema_id
LEFT JOIN sys.sql_modules m ON m.object_id=o.object_id
WHERE o.type IN('V','P','TR') AND o.is_ms_shipped=0
ORDER BY o.type_desc,s.name,o.name;

-- 8. Usuarios, roles y permisos explícitos. No se extraen hashes.
SELECT name,type_desc,authentication_type_desc,default_schema_name
FROM sys.database_principals
WHERE principal_id>4 AND name NOT LIKE N'##%'
ORDER BY type_desc,name;

SELECT rolep.name rol,memberp.name miembro,memberp.type_desc tipo_miembro
FROM sys.database_role_members m
JOIN sys.database_principals rolep ON rolep.principal_id=m.role_principal_id
JOIN sys.database_principals memberp ON memberp.principal_id=m.member_principal_id
ORDER BY rol,miembro;

SELECT USER_NAME(p.grantee_principal_id) destinatario,p.state_desc,
       p.permission_name,p.class_desc,
       CASE p.class WHEN 0 THEN DB_NAME()
                    WHEN 3 THEN SCHEMA_NAME(p.major_id)
                    WHEN 1 THEN OBJECT_SCHEMA_NAME(p.major_id)+N'.'+OBJECT_NAME(p.major_id)
                    ELSE CONVERT(NVARCHAR(20),p.major_id) END ambito
FROM sys.database_permissions p
ORDER BY destinatario,p.class,p.major_id,p.permission_name;
GO
