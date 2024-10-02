# Class Diagram


``` mermaid
classDiagram
    laminr --> RichInstance
    laminr --> UserSettings
    laminr --> InstanceSettings
    RichInstance --|> Instance
    Instance --> API
    Instance --> Module
    Core --|> Module
    Bionty --|> Module
    Module --> Model
    Model --> Field
    Model --> RichRecord
    Artifact --|> Record
    RichInstance --> Core
    RichInstance --> Bionty
    Core --> Artifact
    RichRecord --|> Record
    
    class laminr{
        +connect(String slug): RichInstance
    }

    class UserSettings{
        +initialize(...): UserSettings
        +email: String
        +access_token: String
        +uid: String
        +uuid: String
        +handle: String
        +name: String
    }

    class InstanceSettings{
        +initialize(...): InstanceSettings
        +owner: String
        +name: String
        +id: String
        +schema_id: String
        +api_url: String
    }
    class Instance{
        +initialize(InstanceSettings Instance_settings, API api, Map<String, any> schema): Instance
        +get_modules(): Module[]
        +get_module(String module_name): Module
        +get_module_names(): String[]

    }
    class API{
        +initialize(InstanceSettings Instance_settings)
        +get_schema(): Map~String, Any~
        +get_record(...): RichRecord
    }
    class RichInstance{
        +initialize(InstanceSettings Instance_settings, API api, Map<String, any> schema): RichInstance
        +Model Artifact
        +Model Collection
        +...model accessors...
        +Model User
        +Bionty bionty
    }
    class Core{
        +Model Artifact
        +Model Collection
        +...model accessors...
        +Model User
    }
    class Bionty{
        +Model CellLine
        +Model CellMarker
        +...model accessors...
        +Model Tissue
    }
    class Module{
        +initialize(Instance Instance, API api, String module_name, Map<String, any> module_schema): Module
        +name: String
        +get_models(): Model[]
        +get_model(String model_name): Model
        +get_model_names(): String[]
    }
    class Model{
        +initialize(Instance Instance, Module module, API api, String model_name, Map<String, Any> model_schema): Model
        +name: String
        +class_name: String
        +is_link_table: Bool
        +get_values(): Field[]
        +get_record(String id_or_uid, Bool include_foreign_keys, List~String~ select, Bool verbose): RichRecord
        +cast_data_to_class(Map<String, Any> data): Record
    }
    class Artifact{
        +initialize(...): Artifact
        +cache(): String
        +load(): Any
    }
    class Field{
        +initialize(...): Field
        +type: String
        +through: Map
        +field_name: String
        +model_name: String
        +column_name: String
        +schema_name: String
        +is_link_table: Bool
        +relation_type: String
        +related_field_name: String
        +related_model_name: String
        +related_schema_name: String

    }
    class RichRecord{
        +...field value accessors...
    }
    class Record{
        +initialize(Instance Instance, Model model, API api, Map<String, Any> data): Record
        +get_value(String field_name): Any
    }
```
