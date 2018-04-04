SET NOCOUNT ON

SELECT      A.name COLLATE DATABASE_DEFAULT + '<1>' +
                ISNULL(B.mirroring_role_desc, 'NULL') + '<2>' + 
                ISNULL(B.mirroring_state_desc, 'NULL') + '<3>' + 
                ISNULL(CAST(B.mirroring_role_sequence AS varchar(10)), 'NULL') + '<4>' + 
                ISNULL(B.mirroring_safety_level_desc, 'NULL') + '<5>' +
                ISNULL(B.mirroring_partner_name, 'NULL') + '<6>' +
                ISNULL(B.mirroring_partner_instance, 'NULL') + '<7>' + 
                ISNULL(B.mirroring_witness_name, 'NULL') + '<8>' + 
                ISNULL(B.mirroring_witness_state_desc, 'NULL') + '<9>' + 
                ISNULL(CAST(B.mirroring_connection_timeout AS varchar(10)), 'NULL') + '<10>' +
                ISNULL(B.mirroring_redo_queue_type, 'NULL') 
FROM        sys.databases A
                JOIN sys.database_mirroring B ON A.database_id = B.database_id
WHERE       mirroring_guid IS NOT NULL

