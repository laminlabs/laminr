# Class Diagram


``` mermaid
classDiagram
    laminr --> RichInstance
    laminr --> UserSettings
    laminr --> InstanceSettings
    RichInstance --|> Instance
    Instance --> InstanceAPI
    Instance --> Module
    Core --|> Module
    Bionty --|> Module
    Module --> Registry
    Registry --> Field
    Registry --> RichRecord
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
    class InstanceAPI{
        +initialize(InstanceSettings Instance_settings)
        +get_schema(): Map~String, Any~
        +get_record(...): Map~String, Any~
    }
    class RichInstance{
        +initialize(InstanceSettings Instance_settings, API api, Map<String, any> schema): RichInstance
        +Registry Artifact
        +Registry Collection
        +...registry accessors...
        +Registry User
        +Bionty bionty
    }
    class Core{
        +Registry Artifact
        +Registry Collection
        +...registry accessors...
        +Registry User
    }
    class Bionty{
        +Registry CellLine
        +Registry CellMarker
        +...registry accessors...
        +Registry Tissue
    }
    class Module{
        +initialize(Instance Instance, API api, String module_name, Map<String, any> module_schema): Module
        +name: String
        +get_registries(): Registry[]
        +get_registry(String registry_name): Registry
        +get_registry_names(): String[]
    }
    class Registry{
        +initialize(Instance Instance, Module module, API api, String registry_name, Map<String, Any> registry_schema): Registry
        +name: String
        +class_name: String
        +is_link_table: Bool
        +get_fields(): Field[]
        +get_field(String field_name): Field
        +get_field_names(): String[]
        +get(String id_or_uid, Bool include_foreign_keys, List~String~ select, Bool verbose): RichRecord
        +get_registry_class(): RichRecordClass
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
        +registry_name: String
        +column_name: String
        +module_name: String
        +is_link_table: Bool
        +relation_type: String
        +related_field_name: String
        +related_registry_name: String
        +related_module_name: String

    }
    class RichRecord{
        +...field value accessors...
    }
    class Record{
        +initialize(Instance Instance, Registry registry, API api, Map<String, Any> data): Record
        +get_value(String field_name): Any
    }
```