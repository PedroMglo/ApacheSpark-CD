import warnings
import json
from pyspark.sql.types import (
    StructType, StructField, StringType
)
from pathlib import Path




def paths(folder_path,kind: str,pattern:str = "*"):
    """
    Retorna uma lista de caminhos (paths) para arquivos ou pastas dentro de um diretório,
    opcionalmente filtrados por um padrão (glob).

    Parâmetros
    ----------
    folder_path : str ou pathlib.Path
        Caminho da pasta base onde a busca será realizada.
    kind : {"file", "folder"}
        Tipo de caminho a retornar:
        - "file"  : retorna apenas arquivos.
        - "folder": retorna apenas diretórios.
    pattern : str, opcional
        Padrão de busca no estilo glob (por padrão "*").
        Exemplos:
        - "*.csv"   : todos os arquivos CSV
        - "sub_*"   : arquivos ou pastas cujo nome começa com "sub_"
        - "**/*.py" : todos os arquivos .py recursivamente (se usado com rglob)

    Retorna
    -------
    list[str]
        Lista de caminhos em formato POSIX (strings) correspondentes
        ao tipo (`kind`) e padrão informado dentro de `folder_path`.

    Exemplos
    --------
    >>> _paths("dados", kind="file", pattern="*.csv")
    ['dados/tabela1.csv', 'dados/tabela2.csv']

    >>> _paths("projetos", kind="folder", pattern="exp_*")
    ['projetos/exp_01', 'projetos/exp_02']
    """
    kind = kind.lower()
    
    if kind not in {"file", "folder"}:
        raise ValueError("Nenhum file/folder path atribuido")
    
    base_path = Path(folder_path)
    
    if kind == "file":
        path = [path.as_posix() for path in base_path.glob(pattern) if path.is_file()]

    else:
        path = [path.as_posix() for path in base_path.glob(pattern) if path.is_dir()]
    
    if not path:
        warnings.warn(f"[WARN] Nenhum {kind} encontrado em {base_path} com pattern='{pattern}'")
    return path

def load_schema_json(schema_paths) -> dict:

    schema_path = schema_paths[0] if isinstance(schema_paths, (list)) else schema_paths
    
    with open(schema_path, "r", encoding="utf-8") as f:
        return json.load(f)

def build_schema(table_name: str, schema_json: dict) -> StructType:
    if table_name not in schema_json:
        raise KeyError(f"Tabela {table_name} não encontrada no JSON de schema")
    fields = sorted(schema_json[table_name], key= lambda col: col["column_position"], reverse = False)
    
    return StructType(
       [ StructField(
            field["column_name"]
            ,type_mapping.get(field["data_type"].lower(),StringType())
            ,True
        )
        for field in fields]
    )
