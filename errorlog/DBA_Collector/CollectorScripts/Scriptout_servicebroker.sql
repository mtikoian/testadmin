SELECT

ServiceContract.name AS 'ContractName',

ServiQueue.name AS 'QueueName',

Servi.name AS 'ServiceName',

MessageType.name AS 'MessageType',

MessageUsage.is_sent_by_initiator,

MessageUsage.is_sent_by_target,

MessageType.validation,

MessageType.validation_desc

FROM sys.service_contract_message_usages AS MessageUsage

INNER JOIN sys.service_message_types AS MessageType ON MessageUsage.message_type_id =MessageType.message_type_id

INNER JOIN sys.service_contracts AS ServiceContract ON ServiceContract.service_contract_id =MessageUsage.service_contract_id

INNER JOIN sys.service_contract_usages ServContractUse ON ServContractUse.service_contract_id =ServiceContract.service_contract_id

INNER JOIN sys.services AS Servi ON Servi.service_id=ServContractUse.service_id

INNER JOIN sys.service_queue_usages AS SerQueueUse ON SerQueueUse.service_id = Servi.service_id

INNER JOIN sys.service_queues AS ServiQueue ON ServiQueue.object_id=SerQueueUse.service_queue_id

--you can query your own contract name or even remove WHERE clause

--to see complete list of Service Broker objects in database

--WHERE ServiceContract.name like '%Extreme%'

ORDER By MessageType,QueueName

GO
