
/********************************************
 *	UC: Complementos de Bases de Dados 2023/2024
 *
 *	Turma: 2�L_EI-SW-03 (15:00h - 17:00h)
 *		Nome Aluno: Ricardo Pinto (n� 202200637)
 *		Nome Aluno: Rodrigo Maduro (n� 202200166)
 *	    Nome Aluno: Rodrigo Arraiado (n� 202100436)
 *	
 *			Backups
 *  
 ********************************************/

-- Usar a base de dados AdventureWorks
USE AdventureWorks;

-- Declarar vari�veis
DECLARE @BaseDados NVARCHAR(255) = 'AdventureWorks'
DECLARE @Caminho NVARCHAR(255) = 'D:\Pessoal\Faculdade\2� Ano\1� Semestre\CBD\Projeto-CBD\scripts\Backups\AdventureWorks_PersonBAKS\' 

-- Construir os nomes dos arquivos de backup
DECLARE @BackupCompletoArquivo NVARCHAR(255) = @Caminho + @BaseDados + '_Full_Backup.bak'
DECLARE @BackupDiferencialArquivo NVARCHAR(255) = @Caminho + @BaseDados + '_Backup_Diferencial.bak'
DECLARE @BackupLogsArquivo NVARCHAR(255) = @Caminho + @BaseDados + '_Backup_Log.trn'

-- Comando de Backup Completo
BACKUP DATABASE @BaseDados
TO DISK = @BackupCompletoArquivo
WITH INIT;

PRINT 'Backup completo da Base de dados ' + @BaseDados + ' realizado com sucesso. Caminho do backup: ' + @BackupCompletoArquivo;


WAITFOR DELAY '00:00:10';

-- Verificar se existe um backup completo antes de tentar o backup diferencial
IF (SELECT COUNT(*) FROM msdb.dbo.backupset WHERE database_name = @BaseDados AND type = 'D') > 0
BEGIN
    -- Comando de Backup Diferencial
    BACKUP DATABASE @BaseDados
    TO DISK = @BackupDiferencialArquivo
    WITH DIFFERENTIAL, INIT;

    PRINT 'Backup diferencial da Base de dados ' + @BaseDados + ' realizado com sucesso. Caminho do backup: ' + @BackupDiferencialArquivo;
END
ELSE
BEGIN
    PRINT 'N�o foi poss�vel realizar o backup diferencial. Um backup completo n�o existe.';
END

-- Comando de Backup de Log
BACKUP LOG @BaseDados
TO DISK = @BackupLogsArquivo
WITH INIT;

PRINT 'Backup de log da Base de dados ' + @BaseDados + ' realizado com sucesso. Caminho do backup: ' + @BackupLogsArquivo;



-----------------------------------------------------------------------------------------------------------------------------------
-- Modificar para usar a base de dados master
USE master;

-- Declarar vari�veis novamente
DECLARE @Database NVARCHAR(255) = 'AdventureWorks'
DECLARE @pathTail NVARCHAR(255) = 'D:\Pessoal\Faculdade\2� Ano\1� Semestre\CBD\Projeto-CBD\scripts\Backups\AdventureWorks_PersonBAKS\TailLogs' 
DECLARE @LastFullBackup NVARCHAR(255) 
DECLARE @LastDifferencial NVARCHAR(255) 
DECLARE @LastTransactionLog NVARCHAR(255) 
DECLARE @TailLogPath NVARCHAR(255)

-- Definir o caminho para o Tail Log
SET @TailLogPath = @pathTail + @Database + '_Tail_Log.bak'
-- Fazer backup do log da BD
BACKUP LOG @Database TO DISK = @TailLogPath WITH INIT;

-- Definir caminhos para os backups anteriores
SET @LastFullBackup = 'D:\Pessoal\Faculdade\2� Ano\1� Semestre\CBD\Projeto-CBD\scripts\Backups\AdventureWorks_PersonBAKS\AdventureWorks_Full_Backup.bak'
SET @LastDifferencial = 'D:\Pessoal\Faculdade\2� Ano\1� Semestre\CBD\Projeto-CBD\scripts\Backups\AdventureWorks_PersonBAKS\AdventureWorks_Backup_Diferencial.bak'
SET @LastTransactionLog = 'D:\Pessoal\Faculdade\2� Ano\1� Semestre\CBD\Projeto-CBD\scripts\Backups\AdventureWorks_PersonBAKS\AdventureWorks_Backup_Log.trn'

-- Definir a bd em single_user mode para evitar conex�es
DECLARE @SqlStatement NVARCHAR(MAX);
SET @SqlStatement = 'ALTER DATABASE [' + @Database + '] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;';
EXEC sp_executesql @SqlStatement;

-- Restaura��o do �ltimo Backup Completo
RESTORE DATABASE @Database
FROM DISK = @LastFullBackup
WITH
    NORECOVERY, 
    REPLACE,
    STATS = 10;

-- Restaura��o do �ltimo Backup Diferencial
RESTORE DATABASE @Database
FROM DISK = @LastDifferencial
WITH
    NORECOVERY, 
    STATS = 10;

-- Restaura��o dos Backups de Log
RESTORE LOG @Database
FROM DISK = @LastTransactionLog
WITH
    NORECOVERY, 
    STATS = 10;

-- Recupera��o da Base de Dados
RESTORE DATABASE @Database
WITH RECOVERY;

-- Imprimir mensagem de conclus�o
PRINT 'Recupera��o da Base de Dados ' + @Database + ' conclu�da com sucesso.';
