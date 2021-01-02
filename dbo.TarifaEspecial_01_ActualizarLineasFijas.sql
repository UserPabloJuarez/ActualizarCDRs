
CREATE PROCEDURE [dbo].[TarifaEspecial_01_ActualizarLineasFijas]
AS

declare @sql as varchar(8000)
declare @BBDD as varchar(6)
declare @Cont int

begin

set @BBDD=left(convert(varchar, DATEADD(mm,DATEDIFF(mm,0,GETDATE()),18),112),6)
set @Cont=1

--Cambiamos los cdrs
while (@cont < 5)begin
set @sql='Update CDRS set Precio_fact=(case when CDRS.Chart_time_sec < PRECIOS.Duracion_Fact then PRECIOS.Duracion_Fact * (PRECIOS.Precio/60.0) 
else CDRS.Chart_time_sec * (PRECIOS.Precio/60.0) end),Flag_Tarificado =''P''
FROM
(
SELECT Id_Cliente,Subcliente,Destino,Ambito_llamada,Id_Tarifa,Horario ,Duracion_Fact,Precio,Fecha_Inicio,Fecha_Fin
FROM nfac.dbo.PRECIOS_ESPECIALES with (nolock) WHERE FlagActivo =''S'') as PRECIOS
INNER JOIN
(
SELECT chart_time_sec,Id_cdr,cliente_fact,cliente,ambito_llamada,tarifa_Fact,tramo_horario,destino_detalle,Fecha,Flag_Tarificado,Precio_Fact,Descuento
FROM cdrs_'+ @BBDD +'.dbo.cdrs_0'+ convert(varchar,@Cont) +'_telefonia_fija with (nolock)
WHERE fecha >=convert(varchar, DATEADD(mm,DATEDIFF(mm,0,GETDATE()),0),112) AND fecha <=convert(varchar, DATEADD(mm,DATEDIFF(mm,0,GETDATE()),18),112)
) as CDRS
ON CDRS.cliente_Fact = PRECIOS.id_cliente AND CDRS.cliente = PRECIOS.subcliente AND CDRS.Destino_Detalle = PRECIOS.Destino AND CDRS.Tarifa_fact = PRECIOS.id_tarifa
AND CDRS.ambito_llamada = PRECIOS.ambito_llamada AND CDRS.tramo_horario = PRECIOS.Horario AND CDRS.Fecha between PRECIOS.Fecha_Inicio and PRECIOS.Fecha_Fin
AND CDRS.Flag_Tarificado <>''P'' AND isnumeric(tarifa_fact)=0;'

print 'Se esta Actualizando '+'cdrs_'+ @BBDD +'.dbo.cdrs_0'+ convert(varchar,@Cont)+'_telefonia_fija'

--print @sql
exec (@sql)

set @Cont = @Cont+1;

end

end

begin

while (@cont < 5)begin
SET @sql = '
	select top 1 cliente,cliente_Fact,sum(precio_fact),sum(preco_fact_new), sum(Precio_fact-Preco_Fact_New) diferencia
from (
SELECT distinct cdrs.cliente, CDRS.ID_cdr, CDRS.fecha, CDRS.cliente_Fact, precio as precio_esp, Precio_fact, 
(case when CDRS.Chart_time_sec < PRECIOS.Duracion_Fact then PRECIOS.Duracion_Fact * (PRECIOS.Precio/60.0) else CDRS.Chart_time_sec * (PRECIOS.Precio/60.0) 
end) AS Preco_Fact_New ,flag_tarificado
,''P'' AS Flag_Tarificado_new 
FROM (SELECT Id_Cliente,Subcliente,Destino,Ambito_llamada,Id_Tarifa,Horario ,Duracion_Fact,Precio,Fecha_Inicio,Fecha_Fin
FROM nfac.dbo.PRECIOS_ESPECIALES with (nolock) WHERE --id_cliente=''C62728'' AND
FlagActivo =''S'') as PRECIOS
INNER JOIN
(
SELECT chart_time_sec,Id_cdr,cliente_fact,cliente,ambito_llamada,tarifa_Fact,tramo_horario,destino_detalle,Fecha,Flag_Tarificado,Precio_Fact,Descuento
FROM cdrs_'+ @BBDD +'.dbo.cdrs_0'+ convert(varchar,@Cont) +'_telefonia_fija with (nolock) WHERE --cliente_fact=''C62728'' AND
fecha >=convert(varchar, DATEADD(mm,DATEDIFF(mm,0,GETDATE()),0),112) ) as CDRS
ON CDRS.cliente_Fact = PRECIOS.id_cliente AND CDRS.cliente = PRECIOS.subcliente AND CDRS.Destino_Detalle = PRECIOS.Destino AND CDRS.Tarifa_fact = PRECIOS.id_tarifa
AND CDRS.ambito_llamada = PRECIOS.ambito_llamada AND CDRS.tramo_horario = PRECIOS.Horario AND CDRS.Fecha between PRECIOS.Fecha_Inicio and PRECIOS.Fecha_Fin
AND CDRS.Flag_Tarificado <>''P'' AND isnumeric(tarifa_fact)=0
) as no
group by cliente, cliente_Fact
order by sum(Precio_fact-Preco_Fact_New) + 0 desc;'

print 'Actualizado los '+'cdrs_'+ @BBDD +'.dbo.cdrs_0'+ convert(varchar,@Cont)+'_telefonia_fija'

set @Cont = @Cont+1;
end



execute  msdb..sp_send_dbmail 
		 @profile_name = 'Desarrollo'
		,@recipients = 'pablo.jhim.juarez.castillo@everis.com'        
		,@subject =  'Se ha ejecutado la TarifaEspecial_01_ActualizarLineasFijas'
		,@body ='Se ha ejecutado la TarifaEspecial_01_ActualizarLineasFijas'
		,@query = @sql

	end

GO



/*-----------------------------------------------------------------------------------------------------------------*/

CREATE PROCEDURE [dbo].[TarifaEspecial_01_ActualizarLineasFijas]
AS

declare @sql as varchar(8000)
declare @BBDD as varchar(6)
declare @Cont int

begin

set @BBDD=left(convert(varchar, DATEADD(mm,DATEDIFF(mm,0,GETDATE()),18),112),6)
set @Cont=1
/*
--Cambiamos los cdrs
set @sql='Update CDRS set Precio_fact=(case when CDRS.Chart_time_sec < PRECIOS.Duracion_Fact then PRECIOS.Duracion_Fact * (PRECIOS.Precio/60.0) 
else CDRS.Chart_time_sec * (PRECIOS.Precio/60.0) end),Flag_Tarificado =''P''
FROM
(
SELECT Id_Cliente,Subcliente,Destino,Ambito_llamada,Id_Tarifa,Horario ,Duracion_Fact,Precio,Fecha_Inicio,Fecha_Fin
FROM nfac.dbo.PRECIOS_ESPECIALES with (nolock) WHERE FlagActivo =''S'') as PRECIOS
INNER JOIN
(
SELECT chart_time_sec,Id_cdr,cliente_fact,cliente,ambito_llamada,tarifa_Fact,tramo_horario,destino_detalle,Fecha,Flag_Tarificado,Precio_Fact,Descuento
FROM cdrs_'+ @BBDD +'.dbo.cdrs_01_telefonia_fija with (nolock)
WHERE fecha >=convert(varchar, DATEADD(mm,DATEDIFF(mm,0,GETDATE()),0),112) AND fecha <=convert(varchar, DATEADD(mm,DATEDIFF(mm,0,GETDATE()),18),112)
) as CDRS
ON CDRS.cliente_Fact = PRECIOS.id_cliente AND CDRS.cliente = PRECIOS.subcliente AND CDRS.Destino_Detalle = PRECIOS.Destino AND CDRS.Tarifa_fact = PRECIOS.id_tarifa
AND CDRS.ambito_llamada = PRECIOS.ambito_llamada AND CDRS.tramo_horario = PRECIOS.Horario AND CDRS.Fecha between PRECIOS.Fecha_Inicio and PRECIOS.Fecha_Fin
AND CDRS.Flag_Tarificado <>''P'' AND isnumeric(tarifa_fact)=0;'
*/
--print @sql
--exec (@sql)

end


begin

while (@cont < 5)begin
SET @sql = '
	select top 1 cliente,cliente_Fact,sum(precio_fact),sum(preco_fact_new), sum(Precio_fact-Preco_Fact_New) diferencia
from (
SELECT distinct cdrs.cliente, CDRS.ID_cdr, CDRS.fecha, CDRS.cliente_Fact, precio as precio_esp, Precio_fact, 
(case when CDRS.Chart_time_sec < PRECIOS.Duracion_Fact then PRECIOS.Duracion_Fact * (PRECIOS.Precio/60.0) else CDRS.Chart_time_sec * (PRECIOS.Precio/60.0) 
end) AS Preco_Fact_New ,flag_tarificado
,''P'' AS Flag_Tarificado_new 
FROM (SELECT Id_Cliente,Subcliente,Destino,Ambito_llamada,Id_Tarifa,Horario ,Duracion_Fact,Precio,Fecha_Inicio,Fecha_Fin
FROM nfac.dbo.PRECIOS_ESPECIALES with (nolock) WHERE --id_cliente=''C62728'' AND
FlagActivo =''S'') as PRECIOS
INNER JOIN
(
SELECT chart_time_sec,Id_cdr,cliente_fact,cliente,ambito_llamada,tarifa_Fact,tramo_horario,destino_detalle,Fecha,Flag_Tarificado,Precio_Fact,Descuento
FROM cdrs_'+ @BBDD +'.dbo.cdrs_0'+ convert(varchar,@Cont) +'_telefonia_fija with (nolock) WHERE --cliente_fact=''C62728'' AND
fecha >=convert(varchar, DATEADD(mm,DATEDIFF(mm,0,GETDATE()),0),112) ) as CDRS
ON CDRS.cliente_Fact = PRECIOS.id_cliente AND CDRS.cliente = PRECIOS.subcliente AND CDRS.Destino_Detalle = PRECIOS.Destino AND CDRS.Tarifa_fact = PRECIOS.id_tarifa
AND CDRS.ambito_llamada = PRECIOS.ambito_llamada AND CDRS.tramo_horario = PRECIOS.Horario AND CDRS.Fecha between PRECIOS.Fecha_Inicio and PRECIOS.Fecha_Fin
AND CDRS.Flag_Tarificado <>''P'' AND isnumeric(tarifa_fact)=0
) as no
group by cliente, cliente_Fact
order by sum(Precio_fact-Preco_Fact_New) + 0 desc;'

print 'cdrs_'+ @BBDD +'.dbo.cdrs_0'+ convert(varchar,@Cont)+'_telefonia_fija'

set @Cont = @Cont+1;
end



execute  msdb..sp_send_dbmail 
		 @profile_name = 'Desarrollo'
		,@recipients = 'pablo.jhim.juarez.castillo@everis.com'        
		,@subject =  'Se ha ejecutado la TarifaEspecial_01_ActualizarLineasFijas'
		,@body ='Se ha ejecutado la TarifaEspecial_01_ActualizarLineasFijas'
		,@query = @sql

	end


GO



/*-----------------------------------------------------------------------------------------------------------------*/

ALTER PROCEDURE [dbo].[TarifaEspecial_01_ActualizarLineasFijas]
AS

declare @sql as varchar(8000)
declare @BBDD as varchar(6)

begin

set @BBDD=left(convert(varchar, DATEADD(mm,DATEDIFF(mm,0,GETDATE()),18),112),6)

--Cambiamos los cdrs
set @sql='Update CDRS set Precio_fact=(case when CDRS.Chart_time_sec < PRECIOS.Duracion_Fact then PRECIOS.Duracion_Fact * (PRECIOS.Precio/60.0) 
else CDRS.Chart_time_sec * (PRECIOS.Precio/60.0) end),Flag_Tarificado =''P''
FROM
(
SELECT Id_Cliente,Subcliente,Destino,Ambito_llamada,Id_Tarifa,Horario ,Duracion_Fact,Precio,Fecha_Inicio,Fecha_Fin
FROM nfac.dbo.PRECIOS_ESPECIALES with (nolock) WHERE FlagActivo =''S'') as PRECIOS
INNER JOIN
(
SELECT chart_time_sec,Id_cdr,cliente_fact,cliente,ambito_llamada,tarifa_Fact,tramo_horario,destino_detalle,Fecha,Flag_Tarificado,Precio_Fact,Descuento
FROM cdrs_'+ @BBDD +'.dbo.cdrs_01_telefonia_fija with (nolock)
WHERE fecha >=convert(varchar, DATEADD(mm,DATEDIFF(mm,0,GETDATE()),0),112) AND fecha <=convert(varchar, DATEADD(mm,DATEDIFF(mm,0,GETDATE()),18),112)
) as CDRS
ON CDRS.cliente_Fact = PRECIOS.id_cliente AND CDRS.cliente = PRECIOS.subcliente AND CDRS.Destino_Detalle = PRECIOS.Destino AND CDRS.Tarifa_fact = PRECIOS.id_tarifa
AND CDRS.ambito_llamada = PRECIOS.ambito_llamada AND CDRS.tramo_horario = PRECIOS.Horario AND CDRS.Fecha between PRECIOS.Fecha_Inicio and PRECIOS.Fecha_Fin
AND CDRS.Flag_Tarificado <>''P'' AND isnumeric(tarifa_fact)=0;'

--print @sql
exec (@sql)

end

begin
SET @sql = '
	select cliente,cliente_Fact,sum(precio_fact),sum(preco_fact_new), sum(Precio_fact-Preco_Fact_New) diferencia
from (
SELECT distinct cdrs.cliente, CDRS.ID_cdr, CDRS.fecha, CDRS.cliente_Fact, precio as precio_esp, Precio_fact, 
(case when CDRS.Chart_time_sec < PRECIOS.Duracion_Fact then PRECIOS.Duracion_Fact * (PRECIOS.Precio/60.0) else CDRS.Chart_time_sec * (PRECIOS.Precio/60.0) 
end) AS Preco_Fact_New ,flag_tarificado
,''P'' AS Flag_Tarificado_new 
FROM (SELECT Id_Cliente,Subcliente,Destino,Ambito_llamada,Id_Tarifa,Horario ,Duracion_Fact,Precio,Fecha_Inicio,Fecha_Fin
FROM nfac.dbo.PRECIOS_ESPECIALES with (nolock) WHERE --id_cliente=''C62728'' AND
FlagActivo =''S'') as PRECIOS
INNER JOIN
(
SELECT chart_time_sec,Id_cdr,cliente_fact,cliente,ambito_llamada,tarifa_Fact,tramo_horario,destino_detalle,Fecha,Flag_Tarificado,Precio_Fact,Descuento
FROM cdrs_'+ @BBDD +'.dbo.cdrs_01_telefonia_fija with (nolock) WHERE --cliente_fact=''C62728'' AND
fecha >=convert(varchar, DATEADD(mm,DATEDIFF(mm,0,GETDATE()),0),112) ) as CDRS
ON CDRS.cliente_Fact = PRECIOS.id_cliente AND CDRS.cliente = PRECIOS.subcliente AND CDRS.Destino_Detalle = PRECIOS.Destino AND CDRS.Tarifa_fact = PRECIOS.id_tarifa
AND CDRS.ambito_llamada = PRECIOS.ambito_llamada AND CDRS.tramo_horario = PRECIOS.Horario AND CDRS.Fecha between PRECIOS.Fecha_Inicio and PRECIOS.Fecha_Fin
AND CDRS.Flag_Tarificado <>''P'' AND isnumeric(tarifa_fact)=0
) as no
group by cliente, cliente_Fact
order by sum(Precio_fact-Preco_Fact_New) + 0 desc;'



execute  msdb..sp_send_dbmail 
		 @profile_name = 'Desarrollo'
		,@recipients = 'pablo.jhim.juarez.castillo@everis.com'        
		,@subject =  'Se ha ejecutado la TarifaEspecial_01_ActualizarLineasFijas'
		,@body ='Se ha ejecutado la TarifaEspecial_01_ActualizarLineasFijas'
		,@query = @sql

	end
GO