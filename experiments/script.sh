curl -X 'POST' \
  'https://us-west-2.api.lamin.ai/instances/399387d4-feec-45b5-995d-5b5750f5542c/modules/core/artifact/KBW89Mf7IGcekja2hADu?schema_id=a122335a-0d85-cf36-291d-9e98a6dd1417' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{}'

#{"id":3659,"key":"cell-census/2024-07-01/h5ads/fe52003e-1460-4a65-a213-2bb1a508332f.h5ad","run_id":27,"uid":"KBW89Mf7IGcekja2hADu","hash":"SZ5tB0T4YKfiUuUkAL09ZA","size":691757462,"type":"dataset","suffix":".h5ad","storage_id":2,"version":"2024-07-01","_accessor":"AnnData","is_latest":true,"n_objects":null,"transform_id":22,"_hash_type":"md5-n","created_at":"2024-07-12T12:34:10.345829+00:00","created_by_id":1,"updated_at":"2024-07-12T12:40:48.837026+00:00","visibility":1,"description":"Myeloid compartment","n_observations":51552,"_key_is_virtual":false}

  curl -X 'POST' \
  'https://us-west-2.api.lamin.ai/instances/399387d4-feec-45b5-995d-5b5750f5542c/modules/core/storage/2?schema_id=a122335a-0d85-cf36-291d-9e98a6dd1417' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{}'


curl -X 'POST' \
  'https://us-west-2.api.lamin.ai/instances/399387d4feec45b5995d5b5750f5542c/modules/core/artifact/tczTlSHFPOcAcBnfyxKA?schema_id=a122335a0d85cf36291d9e98a6dd1417&limit_to_many=10' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{"select": ["storage"]}'




curl -X 'POST' \
  'https://us-west-2.api.lamin.ai/instances/399387d4feec45b5995d5b5750f5542c/modules/core/artifact/tczTlSHFPOcAcBnfyxKA?schema_id=a122335a0d85cf36291d9e98a6dd1417&limit_to_many=10' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{"select": ["storage"]}'



curl -X 'POST' \
  'https://us-west-2.api.lamin.ai/instances/399387d4feec45b5995d5b5750f5542c/modules/core/artifact/tczTlSHFPOcAcBnfyxKA?schema_id=a122335a0d85cf36291d9e98a6dd1417&limit_to_many=10' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{"select": ["tissues"]}'