CREATE PROCEDURE [dbo].[Alarma_ProductosFacturasNoCuentaContable]

AS
DECLARE @fecha_inicio as nvarchar(8)
DECLARE @fecha_fin as nvarchar(8)
DECLARE @mailMsg AS VARCHAR(1000)
DECLARE @mail AS VARCHAR(500)
DECLARE @Subj AS VARCHAR(75)
DECLARE @num_fact AS VARCHAR(10)
DECLARE @cod_prod AS VARCHAR(20)
DECLARE @precio_total AS FLOAT
DECLARE @isSendMail as bit
DECLARE @id_empresa as varchar(2)

set @isSendMail = 0

set @fecha_fin = convert(nvarchar,getdate(),112)

if day(getdate())<5 
BEGIN
	--Primer dia del mes anterior
	set @fecha_inicio = CONVERT(VARCHAR(10),LTRIM(RTRIM(STR(DATEPART(YYYY,DATEADD(MM,-1,GETDATE()))))) + '' +RIGHT(REPLICATE('0',1)+LTRIM(RTRIM(STR(DATEPART(MM,DATEADD(MM,-1,GETDATE()))))),2) + '' +'01') 
END
ELSE
BEGIN
	--Primer dia del mes actualual
	set @fecha_inicio = convert(nvarchar,DATEADD(m, DATEDIFF(m,0,getdate()), 0),112)
END

SET @mailMsg='
Las siguientes facturas poseen codigos de productos que generan errores en las cuentas contables:
		Numero Factura		Codigo Producto		Precio Total		Empresa
'

DECLARE cur CURSOR FOR
select hd.num_fact, hd.cod_prod,hd.precio_total,hd.id_empresa
from nfac.dbo.historico_datos hd
	 inner join nfac.dbo.productos_aux pa on pa.cod_prdatos = hd.cod_prod and pa.id_empresa = hd.id_empresa
	 inner join nfac.dbo.historico_facturacion hf on hf.num_fact = hd.num_fact and hf.id_empresa = hd.id_empresa
where pa.descripcion like '%abono%' and hf.sfecha_inicio between @fecha_inicio and @fecha_fin

OPEN cur
FETCH NEXT FROM cur INTO @num_fact,@cod_prod,@precio_total,@id_empresa

WHILE @@FETCH_STATUS=0 BEGIN
	set @mailMsg = @mailMsg + '		   '
	set @mailMsg = @mailMsg + @num_fact + '			        ' + @cod_prod + '		' + convert(nvarchar,round(@precio_total,2)) + '	     	' + @id_empresa
	set @mailMsg = @mailMsg +  CHAR(13) + CHAR(10)
	set @isSendMail = 1 --Correo es enviaddo
	FETCH NEXT FROM cur INTO @num_fact,@cod_prod,@precio_total,@id_empresa
END

CLOSE cur
DEALLOCATE cur

--ENVIO DE MAIL
IF @isSendMail = 1
BEGIN
	SET @mailMsg=@mailMsg + CHAR(13) + CHAR(10) + 'Un Cordial Saludo'

	SET @mail=	'facturacion@masmovil.com'
	SET @subj	= 'Facturas de abonos con Productos Erroneos' 
	EXEC	msdb..sp_send_dbmail 
			@profile_name = N'SistemasMail'
			,@recipients = @mail
			,@subject =  @Subj
			,@body =@mailMsg
END
ELSE
BEGIN
	print 'No Envio Correo'
END
GO
