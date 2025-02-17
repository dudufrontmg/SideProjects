#--------------------------------------------------------------------
# LAYOUT DA TELA WEB

# Botões a esquerda:
# Botão 1: Período
# Botão 2: Projeto
# Botão 3: Atividade

# Total de horas consumida no período (21 a 20/mês) / Projetos / Atividade
#--------------------------------------------------------------------

import streamlit as st
import pandas as pd
import plotly.express as px
#import plotly.graph_objects as go

# layout da página - ocupando todo espaço
st.set_page_config(layout='wide')

# Carrega o arquivo controle_hhs.csv em um "df" = DataFrame
df = pd.read_csv('datasets/controle_hhs.csv', delimiter=';')
# Carregar o arquivo projetos_em_horas.csv
df_projetos_em_horas = pd.read_csv('datasets/projetos_em_horas.csv', delimiter=';')

#------------------------------------------------------------------------------------------
#BOTÃO 1 - PERÍODO

# Corrige o formato da data e ordena os dados pela 'Data Apontamento'
df['Data Apontamento'] = pd.to_datetime(df['Data Apontamento'], format='%d/%m/%Y')
df = df.sort_values('Data Apontamento')

# Função para determinar o mês do apontamento
def custom_month(row):
    if row.day <= 20:
        return str(row.year) + '-' + str(row.month)
    else:
        next_month = row + pd.offsets.MonthBegin(1)
        return str(next_month.year) + '-' + str(next_month.month)

# Cria uma nova coluna 'Month' baseada na 'Data Apontamento'
df['Month'] = df['Data Apontamento'].apply(custom_month)

# SelectBox para selecionar o Período
month = st.sidebar.selectbox('Período (21 a 20)', df['Month'].unique())

# Agora converta a coluna 'Data Apontamento' para string para exibir apenas a data
df['Data Apontamento'] = df['Data Apontamento'].dt.strftime('%d/%m/%Y')

#------------------------------------------------------------------------------------------
#BOTÃO 2 - PROJETO

# Obtém os códigos de projeto únicos e os ordena
projetos_ordenados = df['Código do Projeto'].unique()
projetos_ordenados.sort()

# SelectBox para selecionar o Projeto
projeto_selecionado = st.sidebar.selectbox('Código do Projeto', projetos_ordenados)

#------------------------------------------------------------------------------------------
#BOTÃO 3 - ATIVIDADE

# Colete e ordene todos os valores únicos da coluna 'Descrição da Atividade'
atividades = sorted(df['Descrição da Atividade'].unique().tolist())

# Adicione a opção "Todas as Atividades" no início
atividades.insert(0, "Todas as Atividades")

# Crie o selectbox
atividade_selecionada = st.sidebar.selectbox('Atividade', atividades)

#------------------------------------------------------------------------------------------
# Filtrar os dados com base nos critérios selecionados
df_filtered = df[(df["Month"] == month) & (df['Código do Projeto'] == projeto_selecionado)]

# Se a atividade selecionada não for "Todas as Atividades", aplique o filtro ao seu df_filtered
if atividade_selecionada != "Todas as Atividades":
    df_filtered = df_filtered[df_filtered['Descrição da Atividade'] == atividade_selecionada]

# Usando merge para combinar os dados de df_filtered e df_projetos com base nas colunas especificadas
merged_df = df_filtered.merge(df_projetos_em_horas, 
                              left_on=['Código do Projeto', 'Descrição da Atividade', 'Disciplina'], 
                              right_on=['Cod Projeto', 'Descrição do Item', 'Disciplina'], 
                              how='inner')

#------------------------------------------------------------------------------------------
# DISPLAY - TOTAL HORAS

# Converta as horas apontadas para minutos
def convert_to_minutes(hh_mm_ss_str):
    hh, mm, ss = map(int, hh_mm_ss_str.split(':'))
    return hh * 3600 + mm * 60 + ss

# Aplica a função para converter as horas para segundos
df_filtered['Total Segundos'] = df_filtered['Total Horas'].apply(convert_to_minutes)

# Realize a soma dos segundos
total_seconds = df_filtered['Total Segundos'].sum()

# Converta a soma de volta para o formato de horas, minutos e segundos
hours = total_seconds // 3600
minutes = (total_seconds % 3600) // 60
seconds = total_seconds % 60

# Exibir a soma total das horas apontadas no topo do app
#hours_label = f'{hours}h{minutes}m{seconds}s'
hours_label = f'{hours}:{minutes}:{seconds}'
#st.metric(label="Total Horas", value=hours_label)

# Converta horas, minutos e segundos para formato decimal
decimal_hours = hours + (minutes / 60) + (seconds / 3600)
decimal_hours_label = f'{decimal_hours:.2f} h'

#st.metric(label="Total Horas Decimal", value=decimal_hours_label)

col1, col2, col3, col4, col5 = st.columns([1, 1, 1, 1, 1])

# SE HS ORÇADA uma atividade específica for selecionada
if atividade_selecionada != "Todas as Atividades":
    hs_orcadas = df_projetos_em_horas[(df_projetos_em_horas['Cod Projeto'] == projeto_selecionado) & (df_projetos_em_horas['Descrição do Item'] == atividade_selecionada)]['Hs Orçadas'].iloc[0]
    with col1:
        st.metric("Hs Orçadas por Atividades", f"{hs_orcadas:.2f} h")

# Se "Todas as Atividades" for selecionado
else:
    total_hs_orcadas = df_projetos_em_horas[df_projetos_em_horas['Cod Projeto'] == projeto_selecionado]['Hs Orçadas'].sum()
    with col1:
        st.metric("Hs Orçadas Totais", f"{total_hs_orcadas:.2f} h")
#--------------------------------------------------------------
# SE HS PLANEJADA uma atividade específica for selecionada
if atividade_selecionada != "Todas as Atividades":
    hs_plan = df_projetos_em_horas[(df_projetos_em_horas['Cod Projeto'] == projeto_selecionado) & (df_projetos_em_horas['Descrição do Item'] == atividade_selecionada)]['Hs Programadas'].iloc[0]
    with col2:
        st.metric("Hs Planejadas por Atividades", f"{hs_plan:.2f} h")

# Se "Todas as Atividades" for selecionado
else:
    total_hs_plan = df_projetos_em_horas[df_projetos_em_horas['Cod Projeto'] == projeto_selecionado]['Hs Programadas'].sum()
    with col2:
        st.metric("Hs Planejadas Totais", f"{total_hs_plan:.2f} h")
#--------------------------------------------------------------
# SE HS AJUSTADA uma atividade específica for selecionada
if atividade_selecionada != "Todas as Atividades":
    hs_ajust = df_projetos_em_horas[(df_projetos_em_horas['Cod Projeto'] == projeto_selecionado) & (df_projetos_em_horas['Descrição do Item'] == atividade_selecionada)]['Hs Ajustadas'].iloc[0]
    with col3:
        st.metric("Hs Ajustadas por Atividades", f"{hs_ajust:.2f} h")

# Se "Todas as Atividades" for selecionado
else:
    total_hs_ajust = df_projetos_em_horas[df_projetos_em_horas['Cod Projeto'] == projeto_selecionado]['Hs Ajustadas'].sum()
    with col3:
        st.metric("Hs Ajustadas Totais", f"{total_hs_ajust:.2f} h")
#--------------------------------------------------------------
# SE HS EXECUTADA uma atividade específica for selecionada
if atividade_selecionada != "Todas as Atividades":
    hs_exec = df_projetos_em_horas[(df_projetos_em_horas['Cod Projeto'] == projeto_selecionado) & (df_projetos_em_horas['Descrição do Item'] == atividade_selecionada)]['Hs Executadas'].iloc[0]
    with col4:
        st.metric("Hs Executadas por Atividades", f"{hs_exec:.2f} h")

# Se "Todas as Atividades" for selecionado
else:
    total_hs_exec = df_projetos_em_horas[df_projetos_em_horas['Cod Projeto'] == projeto_selecionado]['Hs Executadas'].sum()
    with col4:
        st.metric("Hs Executadas Totais", f"{total_hs_exec:.2f} h")
#--------------------------------------------------------------
# SE HS SALDO uma atividade específica for selecionada
if atividade_selecionada != "Todas as Atividades":
    hs_saldo = df_projetos_em_horas[(df_projetos_em_horas['Cod Projeto'] == projeto_selecionado) & (df_projetos_em_horas['Descrição do Item'] == atividade_selecionada)]['Hs Saldo'].iloc[0]
    with col5:
        st.metric("Hs Saldo por Atividades", f"{hs_saldo:.2f} h")

# Se "Todas as Atividades" for selecionado
else:
    total_hs_saldo = df_projetos_em_horas[df_projetos_em_horas['Cod Projeto'] == projeto_selecionado]['Hs Saldo'].sum()
    with col5:
        st.metric("Hs Saldo Total", f"{total_hs_saldo:.2f} h")
#---------------------------------------------------------------

# Total Horas Decimal e Total Horas 
#col6, col7 = st.columns([1, 8])
#with col6:
st.metric(label="Total Horas Decimal / Período", value=decimal_hours_label)
#with col7:
st.metric(label="Total Horas / Período", value=hours_label)

#-----------------------------------------------------------------------------------------------------
# Criando um dataframe vazio
df_graph = pd.DataFrame()

# Adicionando as métricas conforme a atividade selecionada
if atividade_selecionada != "Todas as Atividades":
    df_graph['Hs Orçadas'] = [df_projetos_em_horas[(df_projetos_em_horas['Cod Projeto'] == projeto_selecionado) & (df_projetos_em_horas['Descrição do Item'] == atividade_selecionada)]['Hs Orçadas'].iloc[0]]
    df_graph['Hs Planejadas'] = [df_projetos_em_horas[(df_projetos_em_horas['Cod Projeto'] == projeto_selecionado) & (df_projetos_em_horas['Descrição do Item'] == atividade_selecionada)]['Hs Programadas'].iloc[0]]
    df_graph['Hs Ajustadas'] = [df_projetos_em_horas[(df_projetos_em_horas['Cod Projeto'] == projeto_selecionado) & (df_projetos_em_horas['Descrição do Item'] == atividade_selecionada)]['Hs Ajustadas'].iloc[0]]
    df_graph['Hs Executadas'] = [df_projetos_em_horas[(df_projetos_em_horas['Cod Projeto'] == projeto_selecionado) & (df_projetos_em_horas['Descrição do Item'] == atividade_selecionada)]['Hs Executadas'].iloc[0]]
    df_graph['Hs Saldo'] = [df_projetos_em_horas[(df_projetos_em_horas['Cod Projeto'] == projeto_selecionado) & (df_projetos_em_horas['Descrição do Item'] == atividade_selecionada)]['Hs Saldo'].iloc[0]]
else:
    df_graph['Hs Orçadas'] = [df_projetos_em_horas[df_projetos_em_horas['Cod Projeto'] == projeto_selecionado]['Hs Orçadas'].sum()]
    df_graph['Hs Planejadas'] = [df_projetos_em_horas[df_projetos_em_horas['Cod Projeto'] == projeto_selecionado]['Hs Programadas'].sum()]
    df_graph['Hs Ajustadas'] = [df_projetos_em_horas[df_projetos_em_horas['Cod Projeto'] == projeto_selecionado]['Hs Ajustadas'].sum()]
    df_graph['Hs Executadas'] = [df_projetos_em_horas[df_projetos_em_horas['Cod Projeto'] == projeto_selecionado]['Hs Executadas'].sum()]
    df_graph['Hs Saldo'] = [df_projetos_em_horas[df_projetos_em_horas['Cod Projeto'] == projeto_selecionado]['Hs Saldo'].sum()]

# Agora você pode usar df_graph para criar seu gráfico

# 'Derretendo' o dataframe df_graph
df_melted = df_graph.melt(value_vars=["Hs Orçadas", "Hs Planejadas", "Hs Ajustadas", "Hs Executadas", "Hs Saldo"],
                          var_name="Categoria",
                          value_name="Valor")

# Criando o gráfico a partir do df_melted
fig = px.bar(df_melted, x='Categoria', y='Valor', color='Categoria', title="Hs Total x Tipo de Hs",
             labels={"Valor": "Horas", "Categoria": "Tipo de Hora"},
             barmode='relative',
             height=400,
             color_discrete_map={
                 "Hs Orçadas": "green",
                 "Hs Planejadas": "blue",
                 "Hs Ajustadas": "orange",
                 "Hs Executadas": "red",
                 "Hs Saldo": "pink"
             })

st.plotly_chart(fig)



# Gráfico de Total Horas Decimal
#fig2 = px.bar(dados_filtrados, x="Total Horas Decimal", y="Descrição da Atividade", color="Descrição da Atividade", title="Total Horas por Atividade",
#              labels={"value": "Horas"},
#              height=400,
#              color_discrete_map={"Descrição da Atividade": "gray"})

#fig2.show()



# Exibição do df_display
#st.write(df_display)