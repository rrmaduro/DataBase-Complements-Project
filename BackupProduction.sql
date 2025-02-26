
/********************************************
 *	UC: Complementos de Bases de Dados 2023/2024
 *
 *	Turma: 2ºL_EI-SW-03 (15:00h - 17:00h)
 *		Nome Aluno: Ricardo Pinto (nº 202200637)
 *		Nome Aluno: Rodrigo Maduro (nº 202200166)
 *	    Nome Aluno: Rodrigo Arraiado (nº 202100436)
 *	
 *			Backups
 *  
 ********************************************/

-- Usar a base de dados AdventureWorks
USE AdventureWorks;

-- Declarar variáveis
DECLARE @BaseDados NVARCHAR(255) = 'AdventureWorks'
DECLARE @Caminho NVARCHAR(255) = 'D:\Pessoal\Faculdade\2º Ano\1º Semestre\CBD\Projeto-CBD\scripts\Backups\AdventureWorks_ProductionBAKS\' 

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
    PRINT 'Não foi possível realizar o backup diferencial. Um backup completo não existe.';
END

-- Comando de Backup de Log
BACKUP LOG @BaseDados
TO DISK = @BackupLogsArquivo
WITH INIT;

PRINT 'Backup de log da Base de dados ' + @BaseDados + ' realizado com sucesso. Caminho do backup: ' + @BackupLogsArquivo;
