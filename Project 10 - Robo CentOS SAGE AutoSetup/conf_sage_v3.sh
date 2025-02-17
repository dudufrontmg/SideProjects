#!/bin/bash
# -----------------------------------------------------------------------------
# Nome do Projeto   : CentOS SAGE AutoSetup
# Descrição         : Ferramenta em shell que disponibiliza um menu interativo
#                     para a configuração automatizada do SCADA SAGE no ambiente
#                     CentOS, permitindo ajustes seletivos conforme a necessidade.
#
# Autor             : José Eduardo da Neiva Oliveira
# Data de Criação   : 22/03/2023
# Revisão           : v3
#
# Informações:
#   - Total de linhas   : 3651
#   - Total de funções  : ~70
#   - Testes de Homologação:
#         * Linux CentOS 7.9 - Update 29-0
#         * VMware Workstation 16 Player
#
# Uso               : ./conf_sage.sh

#***********************
# INÍCIO DAS FUNÇÕES!!! 
#***********************
#-------------------------------
# VARIÁVEIS
declare -g ON_POS_OPCOES=false
export ON_POS_OPCOES=false
#-------------------------------
# EXTRA-00 - Função clear on/off
#-------------------------------
ON_CLEAR=false

clear_on() {
  ON_CLEAR=true
  if [ "$ON_CLEAR" = true ]; then
    clear
  fi
}
#-------------------------------
# EXTRA-01 - Função pós opções
#-------------------------------
pos_opcoes() {
while true; do
echo "
O que deseja fazer agora?

[ 1 ] Voltar ao menu inicial
[ 2 ] Voltar ao menu inst integral
[ 3 ] Voltar ao menu inst seletiva
[ 4 ] Voltar ao menu testes TAF/TAC
[ 5 ] Voltar ao menu restauração padrão CEPEL
[ 6 ] Voltar ao menu Informações
[ 7 ] Sair do script
-----------------------------------------------------------------------------
Digite a opção desejada e pressione [ENTER]:"
read pos_escolha
case $pos_escolha in

"1")
exibir_menu
break
;;
"2")
instalacao_integral
break
;;
"3")
instalacao_seletiva
break
;;
"4")
testes_taf_tac
break
;;
"5")
padrao_cepel
break
;;
"6")
informacoes
break
;;
"7")
echo "
Saimos do script, ok!"
break
exit 0
;;

*)
echo "
[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:

[CTRL + C] Para sair do script"
;;
esac
done
}
export -f pos_opcoes
#-----------------------------------
# EXTRA-02 - Digitar o nome da base
#-----------------------------------
dig_name_base() {
echo "Digite o nome da base:"
read base
xxx="${base,,}"
export xxx
}
export -f dig_name_base
#-------------------------------
# EXTRA-03 - Função Reiniciar PC
#-------------------------------
reiniciar_pc() {
while true; do
echo "
Gostaria de reiniciar o computador agora?  <S> <N>:"
read reiniciar_pc;
case "$reiniciar_pc" in

[sS]* )
echo "Digite a senha do usuario root";
shutdown -r now
break
;;

[nN]* )
echo "FIM"
break
;;

*)
echo "
[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:

[CTRL + C] Para sair do script"
;;
esac
done
}
export -f reiniciar_pc
#-----------------------------------
# EXTRA-04 - Função Verificar Base
#-----------------------------------
verificar_base() {
local base_a_verificar="$1"
if [ -d "$SAGE/config/${base_a_verificar}" ]; then
return 0
else
return 1
fi
}
export -f verificar_base
#------------------------------------------
# EXTRA 05 - Função copiar backup sagecnf
#------------------------------------------
copia_bkp_sagecnf() {
while true; do
echo "
Deseja copiar o backup sagecnf agora <S> <N>:"
read opcao_copycnf
case "$opcao_copycnf" in
[sS]* )
dig_name_base
found_file=false
for file_copy in $(ls -1 $SAGE/padrao_sscl_cteep/sage/*"$xxx".tar.* 2> /dev/null | sort -t. -k2,2nr); do
if [ -f "$file_copy" ]; then
cp "$file_copy" "$SAGE/"
echo "Arquivo $file_copy copiado com sucesso para $SAGE"
found_file=true
ls -l $SAGE
break
fi
done
if [ "$found_file" = false ]; then
for file_copy in $(ls -1 $SAGE/padrao_sscl_cteep/sage/*"$xxx"_*.tar.Z 2> /dev/null); do
if [ -f "$file_copy" ]; then
cp "$file_copy" "$SAGE/"
echo "Arquivo $file_copy copiado com sucesso para $SAGE"
found_file=true
ls -l $SAGE
break
fi
done
fi
if [ "$found_file" = false ]; then
echo "Nenhum arquivo de backup sagecnf encontrado para a base $base."
fi
break
;;
[nN]* )
break
;;
* )
echo "
[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:

[CTRL + C] Para sair do script"
;;
esac
done
}
export -f copia_bkp_sagecnf
#------------------------------------------
# EXTRA 06 - Função AtualizaBD fria fonte
#------------------------------------------
aff() {
while true; do
echo "
Deseja AtualizarBD fria fonte <S> <N>:"
read atualizabd
case "$atualizabd" in

[sS]* )
gcd_off.rc
sleep 15
AtualizaBD fria fonte
break
;;

[nN]* )
echo "Configuracao interrompida por nao confirmacao!"
break
;;

*)
echo "
[ERRO] Opcao invalida. Tente novamente e pressione [ENTER]:

[CTRL + C] Para sair do script"
;;
esac
done
}
export -f aff
##--------------------------------------------
## EXTRA 13.5 - Função Configurar IEDs no hosts
##---------------------------------------------
#hosts_ieds() {
#while true; do
#echo "Deseja configurar IEDs no arquivo hosts? <S> <N>:"
#read opcao_ied
#case "$opcao_ied" in
#
#[sS]* )
#echo "Quantos IEDs deseja configurar?"
#read num_ied
#if [[ "$num_ied" =~ ^[0-9]+$ ]]; then
#ied_info=""
#for ((i=1; i<=$num_ied; i++)); do
#echo "Digite o IEDName $i no hosts:"
#read ied_name
#echo "Digite o IP do IEDName $i no hosts:"
#read ied_ip
#ied_info="$ied_info$ied_ip\t""host_mms_${ied_name}1\t""host_mms_${ied_name}1b\t""host_mms_${ied_name}2\t""host_mms_${ied_name}2b\t#""${ied_name}\n"
#sed -i '/^/d' /etc/hosts
#echo -e " $hosts_data
#
##GPS
#$gps_info
##SWITCHES
#$switch_info
##REDBOX
#$redbox_info
##TERMINAL SERVER
#$ts_info
##AQUISIÇÃO IEC61850 - IED's
#$ied_info
#" | tee -a /etc/hosts > /dev/null
#
#done
#echo "IEDs configurado com sucesso!"
#echo "----------------------------------------"
#echo "Configurações aplicadas mo arquivo hosts:"
#cat /etc/hosts | tail -n 100
#echo "----------------------------------------"
#break
#else
#echo "Valor inválido! Digite um número."
#fi
#;;
#
#[nN]* )
#echo "Configuração de hosts para IEDs interrompida por não confirmação!"
#break
#;;
#
#*)
#echo "[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:"
#;;
#esac
#done
#}
#
##------------------------------------------------------
## EXTRA 13.4 - Função Configurar Terminal Server no hosts
##------------------------------------------------------
#hosts_ts() {
#while true; do
#echo "Deseja configurar TERMINAL SERVER no arquivo hosts? <S> <N>:"
#read opcao_ts
#case "$opcao_ts" in
#
#[sS]* )
#echo "Quantos TS deseja configurar?"
#read num_ts
#if [[ "$num_ts" =~ ^[0-9]+$ ]]; then
#ts_info=""
#for ((i=1; i<=$num_ts; i++)); do
#echo "Digite o nome do TS $i no hosts:"
#read ts_name
#echo "Digite o IP do TS $i no hosts:"
#read ts_ip
#ts_info="$ts_info$ts_ip	$ts_name"$'\n'
#sed -i '/^/d' /etc/hosts
#echo -e " $hosts_data
#
##GPS
#$gps_info
##SWITCHES
#$switch_info
##REDBOX
#$redbox_info
##TERMINAL SERVER
#$ts_info
#" | tee -a /etc/hosts > /dev/null
#done
#echo "Arquivo hosts configurado com sucesso!"
#echo "----------------------------------------"
#echo "Configurações aplicadas mo arquivo hosts:"
#cat /etc/hosts | tail -n 70
#echo "----------------------------------------"
##hosts_ieds
#break
#else
#echo "Valor inválido! Digite um número."
#fi
#;;
#
#[nN]* )
#echo "Configuração de hosts para TERMINAL SERVER interrompida por não confirmação!"
##hosts_ieds
#break
#;;
#
#*)
#echo "[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:"
#;;
#esac
#done
#}
#
##-----------------------------------------------
## EXTRA 13.3 - Função Configurar REDBOX no hosts
##------------------------------------------------
#hosts_redbox() {
#while true; do
#echo "Deseja configurar REDBOX no arquivo hosts? <S> <N>:"
#read opcao_rb
#case "$opcao_rb" in
#
#[sS]* )
#echo "Quantos REDBOX deseja configurar?"
#read num_redbox
#if [[ "$num_redbox" =~ ^[0-9]+$ ]]; then
#redbox_info=""
#for ((i=1; i<=$num_redbox; i++)); do
#echo "Digite o nome do RB $i no hosts:"
#read redbox_name
#echo "Digite o IP do RB $i no hosts:"
#read redbox_ip
#redbox_info="$redbox_info$redbox_ip	$redbox_name"$'\n'
#sed -i '/^/d' /etc/hosts
#echo -e " $hosts_data
#
##GPS
#$gps_info
##SWITCHES
#$switch_info
##REDBOX
#$redbox_info
#" | tee -a /etc/hosts > /dev/null
#done
#echo "Arquivo hosts configurado com sucesso!"
#echo "----------------------------------------"
#echo "Configurações aplicadas mo arquivo hosts:"
#cat /etc/hosts | tail -n 50
#echo "----------------------------------------"
##hosts_ts
#break
#else
#echo "Valor inválido! Digite um número."
#fi
#;;
#
#[nN]* )
#echo "Configuração de hosts para REDBOX interrompida por não confirmação!"
##hosts_ts
#break
#;;
#
#*)
#echo "[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:"
#;;
#esac
#done
#}
##---------------------------------------------
## EXTRA 13.2 - Função Configurar SWTs no hosts
##---------------------------------------------
#hosts_switches() {
#while true; do
#echo "Deseja configurar SWITCHES no arquivo hosts? <S> <N>:"
#read opcao_swt
#case "$opcao_swt" in
#
#[sS]* )
#echo "Quantos SWITCHES deseja configurar?"
#read num_switches
#if [[ "$num_switches" =~ ^[0-9]+$ ]]; then
#switch_info=""
#for ((i=1; i<=$num_switches; i++)); do
#echo "Digite o nome do SW $i no hosts:"
#read switch_name
#echo "Digite o IP do SW $i no hosts:"
#read switch_ip
#switch_info="$switch_info$switch_ip	$switch_name"$'\n'
#sed -i '/^/d' /etc/hosts
#echo " $hosts_data
#
##GPS
#$gps_info
##SWITCHES
#$switch_info
#" | tee -a /etc/hosts > /dev/null
#done
#echo "Arquivo hosts configurado com sucesso!"
#echo "----------------------------------------
#Linhas adicionadas ao arquivo hosts:"
#cat /etc/hosts | tail -n 20
#echo "----------------------------------------"
##hosts_redbox
#break
#else
#echo "Valor inválido! Digite um número."
#fi
#;;
#
#[nN]* )
#echo "Configuração de hosts para SWITCHES interrompida por não confirmação!"
##hosts_redbox
#break
#;;
#
#*)
#echo "[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:"
#;;
#esac
#done
#}
##-------------------------------------------
## EXTRA 13.1 - Função Configurar GPS no hosts
##-------------------------------------------
#gps_hosts() {
#while true; do
#echo "Deseja adicionar o GPS no arquivo hosts? <S> <N>:"
#read opcao_gps
#case "$opcao_gps" in
#[sS]* )
#echo "Quantos GPS deseja configurar?"
#read num_gps
#if [[ "$num_gps" =~ ^[0-9]+$ ]]; then
#gps_info=""
#for ((i=1; i<=$num_gps; i++)); do
#echo "Digite o nome do GPS $i no hosts:"
#read gps_name
#echo "Digite o IP do GPS $i no hosts:"
#read gps_ip
#gps_info="$gps_info$gps_ip	$gps_name"$'\n'
##gps_info+="$gps_ip\t$gps_name\n"
#sed -i '/^/d' /etc/hosts
#echo " $hosts_data
#
##GPS
#$gps_info
#" | tee -a /etc/hosts > /dev/null
#done
## Atualiza hosts_data em vez de aplicar imediatamente
##hosts_data+="$gps_info"
#echo "Configurações de GPS adicionadas com sucesso."
#echo "----------------------------------------"
#echo "Configurações aplicadas mo arquivo hosts:"
#cat /etc/hosts | tail -n 13
#echo "----------------------------------------"
##hosts_switches
#break
#else
#echo "Valor inválido! Digite um número."
#fi
#;;
#[nN]* )
#echo "Configuração de hosts para GPS interrompida por não confirmação!"
##hosts_switches
#break
#;;
#*)
#echo "[ERRO] Opção inválida. Tente novamente:"
#;;
#esac
#done
#}
#----------------------------------
# OPÇÃO 01 - Função Alterar Senhas
#----------------------------------
alterar_senhas() {
while true; do
echo "
Deseja alterar senhas? <S> <N>:"
read alter_senhas
case "$alter_senhas" in

[sS]* )
echo "
Qual senha deseja alterar?

[  1 ] ambas usuário e root super-usuário
[  2 ] apenas do usuário
[  3 ] apenas do root super-usuário
-----------------------------------------------------------------------------
Digite a opção desejada e pressione [ENTER]:"
read resp_senha;
case "$resp_senha" in
"1")
echo "
Alterando a senha do usuário

Digite a senha do usuario root";
su root -c "passwd sagetr1"
echo "
Alterando a senha do usuário root

Digite a senha atual do usuario root";
su root -c "passwd root"
break
;;

"2")
echo "
Alterando a senha do usuário

Digite a senha do usuario root";
su root -c "passwd sagetr1"
break
;;

"3")
echo "
Alterando a senha do usuário root

Digite a senha atual do usuario root";
su root -c "passwd root"
esac
break
;;

[nN]* )
echo "Alteração de senhas negada!"
break
;;

*)
echo "
[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:

[CTRL + C] Para sair do script"
;;
esac
done
}
export -f alterar_senhas
#-----------------------------------
# OPÇÃO 02 - Função Criar Base Nova
#-----------------------------------
criar_base_nova() {
while true; do
echo "
Deseja criar nova base? <S> <N>:"
read nova_base
case "$nova_base" in

[sS]* )
dig_name_base
echo "
Criando Base $xxx"
cria_base $xxx demo_ems
break
;;

[nN]* )
echo "Criação da base interrompida por não confirmação!"
break
;;

*)
echo "
[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:

[CTRL + C] Para sair do script"
;;
esac
done
}
export -f criar_base_nova
#-----------------------------------
# OPÇÃO 03 - Função alterar hostname
#-----------------------------------
alterar_hostname() {
while true; do
echo "
Deseja alterar o hostname da máquina padrao CTEEP? <S> <N>:"
read alterar_hostname
case "$alterar_hostname" in

[sS]* )
cd /etc
dig_name_base
echo "
Qual servidor SAGE esta configurando?

[ 1 ] sage1
[ 2 ] sage2
---------------------------------------------------
Digite a opção desejada e pressione [ENTER]:"
read opcao
case "$opcao" in
"1") 
echo "
Digite a senha do usuario root"
su root -c "sed -i '1s/.*/'$xxx'-sage1/' hostname"
echo "--------------------------------------
Mudança de hostname efetuado com sucesso!
$xxx-sage1
--------------------------------------------"
break
;;

"2")
echo "
Digite a senha do usuario root"
su root -c "sed -i '1s/.*/'$xxx'-sage2/' hostname"
echo "--------------------------------------
Mudança de hostname efetuado com sucesso!
$xxx-sage2
--------------------------------------------"
esac
break
;;

[nN]* )
echo "Configuração do hostname interrompida por não confirmação!"
break
;;

*)
echo "
[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:

[CTRL + C] Para sair do script"
;;
esac
done
}
export -f alterar_hostname
#--------------------------------
# OPÇÃO 04 - Função habilita base
#--------------------------------
habilitar_base() {
while true; do
echo "
Deseja habilitar a base? <S> <N>:"
read habilitar_base
case "$habilitar_base" in


[nN]* )
echo "Habilitação da base interrompida por não confirmação!"
break
;;

[sS]* )
cd $SAGE
echo "
Digite o nome da base que deseja habilitar:"
read base
xxx="${base,,}"
if verificar_base "$xxx"; then
habilita_base $xxx
sleep 1
echo "--------------------------------------
Base habilitada com sucesso!"
cd $SAGE base "$xxx"
sleep 1
var
echo "--------------------------------------"
reiniciar_pc
break
else
echo "
[ERRO] Base informada não existe. Tente outra e pressione [ENTER]:

[CTRL + C] Para sair do script"
fi
;;
esac
done
}
export -f habilitar_base
#-------------------------------------
# OPÇÃO 05 - Função habilita postgres
#------------------------------------
habilitar_postgres() {
cd $SAGE
while true; do
echo "
Deseja habilitar postgres? <S> <N>:"
read opcao_postgres
case "$opcao_postgres" in

[sS]* )
habilita_postgres
reiniciar_pc
break
;;

[nN]* )
echo "Habilitação interrompida por não confirmação!"
break
;;

*)
echo "
[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:

[CTRL + C] Para sair do script"
;;
esac
done
}
export -f habilitar_postgres
#-------------------------------------
# OPÇÃO 06 - Função instalar calculos
#-------------------------------------
inst_calc() {
cd $SAGE/calculos
while true; do
echo "
Deseja instalar os calculos? <S> <N>:"
read opcao_calc
case "$opcao_calc" in

[sS]* )
instala_calculos
break
;;

[nN]* )
echo "Instalação interrompida por não confirmação!"
break
;;

*)
echo "
[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:

[CTRL + C] Para sair do script"
;;
esac
done
}
export -f inst_calc
#---------------------------------------
# OPÇÃO 07 - Função instalar drivers MMS
#---------------------------------------
inst_mms() {
cd $SAGE/drivers
while true; do
echo "
Deseja instalar o driver mms? <S> <N>:"
read opcao_mms
case "$opcao_mms" in

[sS]* )
echo "
Digite a senha do usuario root";
su root -c "instala_mms"
break
;;

[nN]* )
echo "Instalação interrompida por não confirmação!"
break
;;

*)
echo "
[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:

[CTRL + C] Para sair do script"
;;
esac
done
}
export -f inst_mms
#----------------------------------------------------
# OPÇÃO 08 - Função copiar e instalar a licença SAGE
#----------------------------------------------------
inst_lic() {
while true; do
cd $SAGE
echo "
Deseja copiar o arquivo de licença? <S> <N>:"
read opcao_lic
case "$opcao_lic" in

[sS]* )
echo "
Digite o nome da SE por extenso, conforme arquivo de Licenca. Utilize underline ao inves de espaco."
read SE;
NOME="${SE^^}"
chmod +x $SAGE/padrao_sscl_cteep/sage/*CTEEP_SE_*$NOME*PR*lic*
echo "Copiando arquivo de licença para o diretório $SAGE"
cp $SAGE/padrao_sscl_cteep/sage/*CTEEP_SE_*$NOME*PR*lic* $SAGE/
echo "Licença SAGE copiada com sucesso!"

echo "Instalando licenca do SAGE";
sh *CTEEP_SE_*$NOME*PR*lic*
break
;;

[nN]* )
echo "Instalação interrompida por não confirmação!"
break
;;

*)
echo "
[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:

[CTRL + C] Para sair do script"
;;
esac
done
}
export -f inst_lic
#----------------------------------------------------
# OPÇÃO 09 - Função copiar e instalar update
#----------------------------------------------------
inst_upd() {
while true; do
cd $SAGE
echo "
Deseja copiar o arquivo update? <S> <N>:"
read opcao_upd
case "$opcao_upd" in

[sS]* )
chmod +x $SAGE/padrao_sscl_cteep/sage/*upd*Linux*ems*
echo "Copiando arquivo update para o diretório $SAGE"
cp $SAGE/padrao_sscl_cteep/sage/*upd*Linux*ems* $SAGE/
echo "Arquivo update copiado com sucesso!"

echo "Instalando update do SAGE";
cd $SAGE
instala_update *upd*Linux*ems*
break
;;

[nN]* )
echo "Instalação interrompida por não confirmação!"
break
;;

*)
echo "
[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:

[CTRL + C] Para sair do script"
;;
esac
done
}
export -f inst_upd
#----------------------------------------------------
# OPÇÃO 10 - Função copiar e instalar patches
#----------------------------------------------------
inst_ptc() {
while true; do
cd $SAGE
echo "
Deseja copiar os arquivos patches? <S> <N>:"
read opcao_patch
case "$opcao_patch" in

[sS]* )
chmod +x $SAGE/padrao_sscl_cteep/sage/*patch*Linux*ems*
echo "Copiando arquivos patches para o diretório $SAGE"
cp $SAGE/padrao_sscl_cteep/sage/*patch*Linux*ems* $SAGE/
echo "Arquivos patches copiado com sucesso!"

echo "Instalando patches ao SAGE";
cd $SAGE
instala_patch *patch*Linux*ems*
break
;;

[nN]* )
echo "Instalação interrompida por não confirmação!"
break
;;

*)
echo "
[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:

[CTRL + C] Para sair do script"
;;
esac
done
}
export -f inst_ptc
#----------------------------------------------------------
# OPÇÃO 11 - Função horário de verão - copiar e instalar tz
#----------------------------------------------------------
inst_tz() {
while true; do
echo "
Deseja copiar o arquivo patch instala tz? <S> <N>:"
read opcao_tz
case "$opcao_tz" in

[sS]* )
chmod +x $SAGE/padrao_sscl_cteep/sage/*patch*instala*tz*SAGE*
echo "Copiando arquivo instala_tz para o diretório $SAGE"
cp $SAGE/padrao_sscl_cteep/sage/*patch*instala*tz*SAGE* $SAGE/
echo "Arquivo patch instala_tz copiado com sucesso!"

echo "Descompactando arquivo patch instala_tz..."
zipconfig -x *patch*instala*tz*SAGE*
echo "Descompactado patch instala_tz com sucesso!"

echo "Instalando tz horário de verão";
cd $SAGE/drivers
./instala_tz
zdump -v Brazil/East
echo "Instalação do patch tz horário de verão realizada com sucesso!";
break
;;

[nN]* )
echo "Instalação interrompida por não confirmação!"
break
;;

*)
echo "
[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:

[CTRL + C] Para sair do script"
;;
esac
done
}
export -f inst_tz
#------------------------------------------------
# OPÇÃO 12 - Função configurar arquivo cssagerc
#------------------------------------------------
conf_cssagerc() {
while true; do
cd $SAGE
echo "
Deseja adicionar as linhas de comandos padrão CTEEP no cssagerc? <S> <N>:"
read opcao_cssagerc
case "$opcao_cssagerc" in

[sS]* )
echo "Adicionando linhas de comando para o arquivo cssagerc"
dest="$SAGE/.cssagerc"
temp_file=$(mktemp)

if ! grep -qE '^\s{4}(set history = 1000|set savehist = 1000)' "$dest"; then
#  sed -i '79s/set history = 40/set history = 1000/; 80s/set savehist = 40/set savehist = 1000/' "$dest" #versão1.0
  sed -i '79s/\(set history\s*=\s*\)[0-9]\+/\11000/; 80s/\(set savehist\s*=\s*\)[0-9]\+/\11000/' "$dest"
fi

if ! grep -qE '^\s{4}(# Aliases PADRÃO CTEEP|alias on|alias off|alias aff|alias daa|alias erro|alias extra)' "$dest"; then

awk '
  NR==81 {
    print "    # Aliases PADRÃO CTEEP"
    print "    alias on '\''ativa gcd'\''"
    print "    alias off '\''desativa gcd'\''"
    print "    alias aff '\''AtualizaBD fria fonte_bd'\''"
    print "    alias daa '\''desativa gcd && sleep 5 && AtualizaBD fria fonte_bd && sleep 5 && ativa gcd'\''"
    print "    alias erro '\''egrep \"E:|Erro|ERRO|-E\" /tmp/sagetr1/log/STI_cargbf.log'\''"
    print "    alias extra '\''egrep \"EXTRA\" $LOG/unix.log'\''"
  }
  { print }
' "$dest" > "$temp_file"

  if [ $? -eq 0 ]; then
    mv "$temp_file" "$dest"
	sleep 1
  fi
fi

if [ $? -eq 0 ]; then
echo "--------------------------------------------------------------------------------------------------------"
echo "Arquivo cssagerc configurado com sucesso!"
echo "Linhas existentes alteradas:"
grep -E '^\s{4}(set history|set savehist)' "$dest"
echo "Linhas adicionadas:"
grep -E '^\s{4}(# Aliases PADRÃO CTEEP|alias on|alias off|alias aff|alias daa|alias erro|alias extra)' "$dest"
echo "--------------------------------------------------------------------------------------------------------"
fi
break
;;

[nN]* )
echo "Instalação interrompida por não confirmação!"
break
;;

*)
echo "
[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:

[CTRL + C] Para sair do script"
;;
esac
done
}
export -f conf_cssagerc
######################################
# OPÇÃO 13 - Função Configurar o hosts
######################################
#-----------------------------------------------------------------------------------
# Função EXTRA 13.0 - Ação de contêiner para armazenar as configs aplicadas em hosts
##-----------------------------------------------------------------------------------
#conf_hosts() {
#echo "Entrando em hosts"
#while true; do
#cd /etc
#echo "Deseja configurar o hosts iniciando o padrão difusão e distribuição com COT? <S> <N>:"
#read opcao_hosts_s
#case "$opcao_hosts_s" in
#
#[sS]* )
#dig_name_base
#export xxx
#hosts_data=$(cat <<-EOF
#127.0.0.1   localhost localhost.localdomain
#::1         localhost localhost.localdomain
#
## Rede de Difusao SAGE
#10.10.10.11    $xxx-sage1
#10.10.10.12    $xxx-sage2
#
## Distribuicao i104 COT BOJ/CAV
#192.168.12.41	host_104_1_1	#servidor 1 rota BOJ
#192.168.12.42	host_104_1_1b	#servidor 2 rota BOJ
#192.168.22.41	host_104_1_2	#servidor 1 rota CAV
#192.168.22.42	host_104_1_2b	#servidor 2 rota CAV
#EOF
#)
#cp /etc/hosts /etc/hosts.bak
#echo "----------------------------------------
#Criando backup de segurança do arquivo hosts como hosts.bak:"
#sleep 2
#echo "$hosts_data" > /etc/hosts
#echo "----------------------------------------"
#echo "Configurações aplicadas mo arquivo hosts:"
#echo -e "$hosts_data"
#echo "----------------------------------------"
##gps_hosts
#break
#;;
#
#[nN]* )
#echo "Configuração interrompida por não confirmação!"
#break
#;;
#
#*)
#echo "[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:"
#echo "[CTRL + C] Para sair do script"
#;;
#esac
#done
#}
#######################################################################
# Pedir a senha de root e executar todas as configurações uma única vez
#######################################################################
#executar_configuracoes() {
#conf_hosts
#gps_hosts
#hosts_switches
#hosts_redbox
#hosts_ts
#hosts_ieds
#exit 0
#}
#echo "Digite a senha do usuário root para continuar:"
#su root -c "$(declare -f conf_hosts gps_hosts hosts_switches hosts_redbox hosts_ts hosts_ieds executar_configuracoes); executar_configuracoes"
#--------------------------------------------------------------------
# EXTRA - Função Conversão de máscara subrede para formato CIDR
#--------------------------------------------------------------------
subnet_to_cidr() {
local subnet=$1
local cidr=0
for octet in $(echo $subnet | tr '.' ' '); do
local bin_octet=$(echo "obase=2; ibase=10; $octet" | bc)
cidr=$(($cidr + $(echo $bin_octet | tr -cd '1' | wc -c)))
done
echo $cidr
}
export -f subnet_to_cidr
#--------------------------------------------------------------------
# EXTRA - Função Conversão de máscara subrede para formato CIDR
#--------------------------------------------------------------------
restart_network() {
while true; do
echo "Deseja restartar as interfaces de rede agora? <S> <N>:"
read resposta_sim
case $resposta_sim in

[sS]* )
echo "Restartando as interfaces de rede, aguarde..."
su root -c "systemctl restart network"
ifconfig
break
;;

[nN]* )
echo "Restart negado!"
sleep 1
break
;;

*)
echo "[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:"

echo "[CTRL + C] Para sair do script"
;;
esac
done
}
export -f restart_network
#--------------------------------------------------------------------
# OPÇÃO 14 - Função Configurar interface de rede da difusao confiavel
#--------------------------------------------------------------------
rede_dc() {
while true; do
cd /etc/sysconfig/network-scripts/

echo "Deseja configurar a interface de rede da difusao confiavel padrao CTEEP? <S> <N>:"
read resposta_dc
case $resposta_dc in

[sS]* )
echo "Digite a senha do usuário root:"
su root -c "
echo '-----------------------------------------------'
echo 'Interfaces de rede existentes em seu servidor!'
echo
ls -1 ifcfg-*
echo
echo '---------------------------------------------------------------------------------------------------------'
echo 'Digite o nome completo da interface de rede que sera configurado a difusao confiavel, exemplo: ifcfg-xxx?'
read interface_dc
echo 'Qual o IP da difusao confiavel?'
read ip_dc
echo 'Qual a máscara de rede?'
read subnet

prefix_dc=$(subnet_to_cidr $subnet)

sed -i 's/BOOTPROTO=dhcp/BOOTPROTO=none/' '/etc/sysconfig/network-scripts/$interface_dc'
sed -i 's/ONBOOT=no/ONBOOT=yes/' '/etc/sysconfig/network-scripts/$interface_dc'

echo 'Novo valor de IPADDR: $ip_dc' # Debug
echo 'Novo valor de PREFIX: $prefix_dc' # Debug

if grep -q 'IPADDR=' '/etc/sysconfig/network-scripts/$interface_dc'; then
sed -i 's/IPADDR=.*/IPADDR=$ip_dc/' '/etc/sysconfig/network-scripts/$interface_dc'
else
'IPADDR=$ip_dc' >> '/etc/sysconfig/network-scripts/$interface_dc'
fi

if grep -q 'PREFIX=' '/etc/sysconfig/network-scripts/$interface_dc'; then
sed -i 's/PREFIX=.*/PREFIX=$prefix_dc/' '/etc/sysconfig/network-scripts/$interface_dc'
else
'PREFIX=$prefix_dc' >> '/etc/sysconfig/network-scripts/$interface_dc'
fi

echo '---------------------------------------------------------------'
echo 'Interface de rede da difusao confiavel configurada com sucesso!'
echo
cat '/etc/sysconfig/network-scripts/$interface_dc'
echo '---------------------------------------------------------------'
echo 'Ativando a interface de rede $interface_dc, aguarde...'
echo
echo 'Interface de rede $interface_dc ativa com sucesso!'
ifup $interface_dc
echo 'Restartando as interfaces de rede...'
systemctl restart network
echo '---------------------------------------------------------------'
"
echo 'Rede de difusao confiavel configurada e ativada com sucesso!'
ifconfig
echo "---------------------------------------------------------------"
break
;;

[nN]* )
echo "Configuração de rede interrompida por não confirmação!"
break
;;

*)
echo "[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:"

echo "[CTRL + C] Para sair do script"
;;
esac
done
}
export -f rede_dc
#---------------------------------------------------------------
# OPÇÃO 15 - Funcao criar e configurar interface logica Bonding
#---------------------------------------------------------------
rede_bond() {
while true; do
cd /etc/sysconfig/network-scripts/
echo "Deseja criar e configurar a interface de rede logica bonding padrao CTEEP? <S> <N>:"
read resposta_bond
case $resposta_bond in

[sS]* )
echo "Digite a senha do usuário root:"
su root -c "
echo 'Qual o IP do bond0?'
read ip_bond
echo 'Qual a máscara de rede?'
read subnet

prefix_bond=$(subnet_to_cidr $subnet)

echo 'Ativando o modulo bonding...'
echo '--------------------------------------------------------------------'
echo 'Modulo bonding ativado com sucesso!'
modprobe --first-time bonding
echo
modinfo bonding
echo '--------------------------------------------------------------------'
if [ -f '/etc/sysconfig/network-scripts/ifcfg-bond0' ]; then
echo 'Arquivo ifcfg-bond0 já existe. Removendo...'
rm /etc/sysconfig/network-scripts/ifcfg-bond0
fi
echo 'Criando interface logica bond como bond0...'
echo
touch '/etc/sysconfig/network-scripts/ifcfg-bond0'
sleep 2
echo 'Criando interface logica bond0 com sucesso!'
ls -1 ifcfg-*
echo 'Configurando interface logica bond0...'
echo 'DEVICE=bond0' | tee /etc/sysconfig/network-scripts/ifcfg-bond0 > /dev/null
echo 'NAME=bond0' | tee -a /etc/sysconfig/network-scripts/ifcfg-bond0 > /dev/null
echo 'TYPE=Bond' | tee -a /etc/sysconfig/network-scripts/ifcfg-bond0 > /dev/null
echo 'BONDING_MASTER=yes' | tee -a /etc/sysconfig/network-scripts/ifcfg-bond0 > /dev/null
echo 'IPADDR=$ip_bond' | tee -a /etc/sysconfig/network-scripts/ifcfg-bond0 > /dev/null
echo 'PREFIX=$prefix_bond' | tee -a /etc/sysconfig/network-scripts/ifcfg-bond0 > /dev/null
echo 'ONBOOT=yes' | tee -a /etc/sysconfig/network-scripts/ifcfg-bond0 > /dev/null
echo 'BOOTPROTO=none' | tee -a /etc/sysconfig/network-scripts/ifcfg-bond0 > /dev/null
echo 'BONDING_OPTS="mode=1 miimon=100"' | tee -a /etc/sysconfig/network-scripts/ifcfg-bond0 > /dev/null
echo '--------------------------------------------------------------------'
echo 'Interface logica bond0 criada e configuradacom sucesso!'
echo
cat '/etc/sysconfig/network-scripts/ifcfg-bond0'
echo '--------------------------------------------------------------------'
echo 'Restartando as interfaces de rede...'
systemctl restart network
sleep 2
"
ifconfig
break
;;

[nN]* )
echo "Configuração de rede interrompida por não confirmação!"
break
;;

*)
echo "[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:"

echo "[CTRL + C] Para sair do script"
;;
esac
done
}
export -f rede_bond
#-------------------------------------------------------------------
# OPÇÃO 17 - Função Configurar interface de rede de aquisicao 61850
#-------------------------------------------------------------------
rede_rele() {
while true; do
cd /etc/sysconfig/network-scripts/
echo "Deseja configurar a interface de rede para aquisição 61850 padrao CTEEP? <S> <N>:"
read resposta_aquisicao
case $resposta_aquisicao in

[sS]* )
echo "Digite a senha do usuário root:"
su root -c "
echo '----------------------------------------------------------'
echo 'Quantas interfaces de rede fisica 61850 deseja configurar?'
read num_inter_rede
if [[ '$num_inter_rede' =~ ^[0-9]+$ ]]; then
num_inter_info=""
for ((i=1; i<=$num_inter_rede; i++)); do
echo 'Interfaces de rede existentes em seu servidor!'
echo
ls -1 ifcfg-*
echo
echo '-----------------------------------------------------------------------'
echo 'Digite o nome da interface de rede de aquisicao $i, exemplo: ifcfg-xxx?'
read name_rede_aq
if [[ -z '$name_rede_aq' ]]; then
echo 'Nome de interface inválido. Tente novamente.'
break
fi
num_inter_info='$num_inter_info$name_rede_aq'$'\n'

#Verifica se já há IPADDR e PREFIX configurados
if grep -q '^IPADDR=' '$name_rede_aq' && grep -q '^PREFIX=' '$name_rede_aq'; then
#Se sim, remove as linhas de configuração IPADDR e PREFIX
sed -i '/^IPADDR=/d' '$name_rede_aq'
sed -i '/^PREFIX=/d' '$name_rede_aq'
fi
#Editar e adicionar os atributos
sed -i 's/BOOTPROTO=dhcp/BOOTPROTO=none/' '$name_rede_aq'
sed -i 's/ONBOOT=no/ONBOOT=yes/' '$name_rede_aq'
sed -i '/^PROXY_METHOD=/d' '$name_rede_aq'
sed -i '/^BROWSER_ONLY=/d' '$name_rede_aq'
sed -i 's/^ETHTOOL_OPTS=.*/&\nMASTER=bond0\nSLAVE=yes/' '$name_rede_aq'
done
echo '----------------------------------------------------------'
echo 'Interfaces de rede de aquisicao configuradas com sucesso!'
echo 
cat '/etc/sysconfig/network-scripts/$num_inter_info'
echo '----------------------------------------------------------'
echo 'Ativando as interfaces de rede $num_inter_info, aguarde...'
echo
echo 'Interfaces de rede $num_inter_info ativas com sucesso!'
ifup $num_inter_info
echo 'Restartando as interfaces de rede...'
systemctl restart network
"
echo '---------------------------------------------------------------'
echo 'Redes configuradas e ativadas com sucesso!'
ifconfig
echo '---------------------------------------------------------------'
break
else
echo "Quantidade inválida. Tente novamente."
break
fi
;;

[nN]* )
echo "Configuração interrompida por não confirmação!"
break
;;

*)
echo "[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:

[CTRL + C] Para sair do script"
;;
esac
done
}
export -f rede_rele
#------------------------------------------------------------------------
# OPÇÃO 17 - Função Configurar interface de rede de distribuicao para BOJ
#------------------------------------------------------------------------
rede_boj() {
while true; do
cd /etc/sysconfig/network-scripts/
echo "Deseja configurar a interface de rede para distribuição do COT BOJ padrao CTEEP? <S> <N>:"
read resposta_boj
case $resposta_boj in

[sS]* )
echo "Digite a senha do usuário root:"
su root -c "
echo '-----------------------------------------------'
echo 'Interfaces de rede existentes em seu servidor!'
echo
ls -1 ifcfg-*
echo
echo '-------------------------------------------------------------------------------------------------------------------'
echo 'Digite o nome completo da interface de rede que sera configurado a distribuição para o COT BOJ, exemplo: ifcfg-xxx?'
read interface_boj
echo '-------------------------------------------------------------------------------------------------------------------'
echo 'Qual o IP para COT BOJ?'
read ip_boj
echo 'Qual a máscara de rede?'
read subnet

prefix_boj=$(subnet_to_cidr $subnet)

sed -i 's/BOOTPROTO=dhcp/BOOTPROTO=none/' '/etc/sysconfig/network-scripts/$interface_boj'
sed -i 's/ONBOOT=no/ONBOOT=yes/' '/etc/sysconfig/network-scripts/$interface_boj'

echo 'Novo valor de IPADDR: $ip_boj' # Debug
echo 'Novo valor de PREFIX: $prefix_boj' # Debug

if grep -q 'IPADDR=' '/etc/sysconfig/network-scripts/$interface_boj'; then
sed -i 's/IPADDR=.*/IPADDR=$ip_dc/' '/etc/sysconfig/network-scripts/$interface_boj'
else
'IPADDR=$ip_dc' >> '/etc/sysconfig/network-scripts/$interface_boj'
fi

if grep -q 'PREFIX=' '/etc/sysconfig/network-scripts/$interface_boj'; then
sed -i 's/PREFIX=.*/PREFIX=$prefix_boj/'
 '/etc/sysconfig/network-scripts/$interface_boj'
else
'PREFIX=$prefix_boj' >> '/etc/sysconfig/network-scripts/$interface_boj'
fi

echo '--------------------------------------------------------------------'
echo 'Ativando a interface de rede $interface_boj, aguarde...'
echo
echo 'Interface de rede $interface_boj ativa com sucesso!'
ifup $interface_boj
echo 'Restartando as interfaces de rede...'
systemctl restart network
echo '--------------------------------------------------------------------'
echo 'Interface de rede da Distribuicao COT-CAV configurada com sucesso!'
echo
cat '/etc/sysconfig/network-scripts/$interface_boj'
ifconfig
echo '--------------------------------------------------------------------'
echo 'Configuracao da interface da rota de distribuicao para COT-CAV...'
echo
ls -1 ifcfg-*
echo 'Qual o IP para a rota COT BOJ?'
read ip_rot_boj
echo 'Qual a máscara de rede para a rota COT BOJ?'
read subnet
echo 'Qual o Gateway para a rota COT BOJ?'
read gw_rot_boj

prefix_rot_boj=$(subnet_to_cidr $subnet)

route_file_boj='route-${interface_boj/ifcfg-/}'
interface_route='$route_file_boj'
touch '/etc/sysconfig/network-scripts/$route_file_boj'
echo 'ADDRESS0=$ip_rot_boj' > '/etc/sysconfig/network-scripts/route_file/$route_file_boj'
echo 'NETMASK0=$prefix_rot_boj' >> '/etc/sysconfig/network-scripts/route_file/$route_file_boj'
echo 'GATEWAY0=$gw_rot_boj' >> '/etc/sysconfig/network-scripts/route_file/$route_file_boj'
echo '--------------------------------------------------------------------'
echo 'Interface da rota de distribuicao para COT-BOJ configurada com sucesso!'
echo
cat /etc/sysconfig/network-scripts/$route_file_boj
echo
echo '--------------------------------------------------------------------'
echo 'Ativando a rota de distribuicao configurada para COT-BOJ...!'
echo
route -v add -net $ip_rot_boj/$prefix_rot_boj gw $gw_rot_boj
echo 'Restartando as interfaces de rede...'
systemctl restart network
echo '--------------------------------------------------------------------'
echo 'Rota configurada e ativada com sucesso!'
route -n
echo '--------------------------------------------------------------------'
"
break
;;

[nN]* )
echo "Configuração de rede interrompida por não confirmação!"
break
;;

*)
echo "[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:"

echo "[CTRL + C] Para sair do script"
;;
esac
done
}
export -f rede_boj
#------------------------------------------------------------------------
# OPÇÃO 18 - Função Configurar interface de rede de distribuicao para CAV
#------------------------------------------------------------------------
rede_cav() {
while true; do
cd /etc/sysconfig/network-scripts/
echo "Deseja configurar a interface de rede para distribuição do COT CAV padrao CTEEP? <S> <N>:"
read resposta_cav
case $resposta_cav in

[sS]* )
echo "Digite a senha do usuário root:"
su root -c "
echo '-----------------------------------------------'
echo 'Interfaces de rede existentes em seu servidor!'
echo
ls -1 ifcfg-*
echo
echo '-------------------------------------------------------------------------------------------------------------------'
echo 'Digite o nome completo da interface de rede que sera configurado a distribuição para o COT CAV, exemplo: ifcfg-xxx?'
read interface_cav
echo '-------------------------------------------------------------------------------------------------------------------'
echo 'Qual o IP para COT CAV?'
read ip_cav
echo 'Qual a máscara de rede?'
read subnet

prefix_cav=$(subnet_to_cidr $subnet)

sed -i 's/BOOTPROTO=dhcp/BOOTPROTO=none/' '/etc/sysconfig/network-scripts/$interface_cav'
sed -i 's/ONBOOT=no/ONBOOT=yes/' '/etc/sysconfig/network-scripts/$interface_cav'

echo 'Novo valor de IPADDR: $ip_cav' # Debug
echo 'Novo valor de PREFIX: $prefix_cav' # Debug

if grep -q 'IPADDR=' '/etc/sysconfig/network-scripts/$interface_cav'; then
sed -i 's/IPADDR=.*/IPADDR=$ip_dc/' '/etc/sysconfig/network-scripts/$interface_cav'
else
'IPADDR=$ip_dc' >> '/etc/sysconfig/network-scripts/$interface_cav'
fi

if grep -q 'PREFIX=' '/etc/sysconfig/network-scripts/$interface_cav'; then
sed -i 's/PREFIX=.*/PREFIX=$prefix_cav/' '/etc/sysconfig/network-scripts/$interface_cav'
else
'PREFIX=$prefix_cav' >> '/etc/sysconfig/network-scripts/$interface_cav'
fi

echo '--------------------------------------------------------------------'
echo 'Ativando a interface de rede $interface_cav, aguarde...'
echo
echo 'Interface de rede $interface_cav ativa com sucesso!'
ifup $interface_cav
echo 'Restartando as interfaces de rede...'
systemctl restart network
echo '--------------------------------------------------------------------'
echo 'Interface de rede da Distribuicao COT-CAV configurada com sucesso!'
echo
cat '/etc/sysconfig/network-scripts/$interface_cav'
ifconfig
echo '--------------------------------------------------------------------'
echo 'Configuracao da interface da rota de distribuicao para COT-CAV...'
echo
ls -1 ifcfg-*
echo 'Qual o IP para a rota COT CAV?'
read ip_rot_cav
echo 'Qual a máscara de rede para a rota COT CAV?'
read subnet
echo 'Qual o Gateway para a rota COT CAV?'
read gw_rot_cav

prefix_rot_cav=$(subnet_to_cidr $subnet)

route_file_cav='route-${interface_cav/ifcfg-/}'
interface_route='$route_file_cav'
touch '/etc/sysconfig/network-scripts/$interface_route_cav'
echo 'ADDRESS0=$ip_rot_cav' > '/etc/sysconfig/network-scripts/route_file/$interface_route_cav'
echo 'NETMASK0=$prefix_rot_cav' >> '/etc/sysconfig/network-scripts/route_file/$interface_route_cav'
echo 'GATEWAY0=$gw_rot_cav' >> '/etc/sysconfig/network-scripts/route_file/$interface_route_cav'
echo '--------------------------------------------------------------------'
echo 'Interface da rota de distribuicao para COT-CAV configurada com sucesso!'
echo
cat /etc/sysconfig/network-scripts/$interface_route_cav
echo
echo '--------------------------------------------------------------------'
echo 'Ativando a rota de distribuicao configurada para COT-CAV...!'
echo
route -v add -net $ip_rot_cav/$prefix_rot_cav gw $gw_rot_cav
echo 'Restartando as interfaces de rede...'
systemctl restart network
echo '--------------------------------------------------------------------'
echo 'Rota configurada e ativada com sucesso!'
route -n
echo '--------------------------------------------------------------------'
"
break
;;

[nN]* )
echo "Configuração de rede interrompida por não confirmação!"
break
;;

*)
echo "[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:"

echo "[CTRL + C] Para sair do script"
;;
esac
done
}
export -f rede_cav
##########################################################################
# Adicionando comentários e adicionando linhas servidores padrão ntp.conf
#########################################################################
comentar_srv_default() {
sed -i 's/^server 0\.centos\.pool\.ntp\.org.*/#&/' /etc/ntp.conf
sed -i 's/^server 1\.centos\.pool\.ntp\.org.*/#&/' /etc/ntp.conf
sed -i 's/^server 2\.centos\.pool\.ntp\.org.*/#&/' /etc/ntp.conf
sed -i 's/^server 3\.centos\.pool\.ntp\.org.*/#&/' /etc/ntp.conf
echo "As seguintes linhas server default foram comentadas com sucesso:"
echo
grep 'server [0-3]\.centos\.pool\.ntp\.org.*' /etc/ntp.conf
echo "------------------------------------------------------------------"
break
}
#################################################################################
# Função extra para remover as linhas padrão antes de adicionar as novas
function remove_ntp_lines {
sed -i '/^server 127\.127\.1\.0/d' /etc/ntp.conf
sed -i '/^fudge 127\.127\.1\.0 stratum 10/d' /etc/ntp.conf
sed -i '/^server gps1/d' /etc/ntp.conf
sed -i '/^server gps2/d' /etc/ntp.conf
sed -i '/^peer/d' /etc/ntp.conf
}
export -f remove_ntp_lines
#################################################################################
# Função para adicionar as linhas ao arquivo
function sage1_2gps {
echo "Digite a senha do usuário root:"
read -s password
remove_ntp_lines # chama a função para remover as linhas existentes
sleep 1.5
# Encontra a linha "server 3.centos.pool.ntp.org iburst" e adiciona as novas linhas logo abaixo
sed -i -r \
-e '/^#*\s*server 3\.centos\.pool\.ntp\.org( iburst)?/a \
server 127.127.1.0\
fudge 127.127.1.0 stratum 10\
server gps1\
server gps2' /etc/ntp.conf
echo "------------------------------------------------------------------"
echo "As seguintes linhas foram adicionadas com sucesso:"
echo 
echo "server 127.127.1.0"
echo "fudge 127.127.1.0 stratum 10"
echo "server gps1"
echo "server gps2"
echo "------------------------------------------------------------------"
}
export -f sage1_2gps
#################################################################################
# Função extra para remover as linhas padrão antes de adicionar as novas
#################################################################################
function sage1_1gps {
echo "Digite a senha do usuário root:"
read -s password
remove_ntp_lines # chama a função para remover as linhas existentes
sleep 1.5
# Encontra a linha "server 3.centos.pool.ntp.org iburst" e adiciona as novas linhas logo abaixo
sed -i -r \
-e '/^#*\s*server 3\.centos\.pool\.ntp\.org( iburst)?/a \
server 127.127.1.0\
fudge 127.127.1.0 stratum 10\
server gps1' /etc/ntp.conf
echo "------------------------------------------------------------------"
echo "As seguintes linhas foram adicionadas com sucesso:"
echo
echo "server 127.127.1.0"
echo "fudge 127.127.1.0 stratum 10"
echo "server gps1"
echo "------------------------------------------------------------------"
}
export -f sage1_1gps
#################################################################################
# Função para adicionar as linhas ao arquivo
#################################################################################
function sage2_2gps {
echo "Digite a senha do usuário root:"
read -s password
remove_ntp_lines # chama a função para remover as linhas existentes
sleep 1.5
# Encontra a linha "server 3.centos.pool.ntp.org iburst" e adiciona as novas linhas logo abaixo
sed -i -r \
-e '/^#*\s*server 3\.centos\.pool\.ntp\.org( iburst)?/a \
server gps1\
server gps2\
peer' /etc/ntp.conf
echo "------------------------------------------------------------------"
echo "As seguintes linhas foram adicionadas com sucesso:"
echo
echo "server gps1"
echo "server gps2"
echo "peer"
echo "------------------------------------------------------------------"
}
export -f sage2_2gps
#################################################################################
# Função para adicionar as linhas ao arquivo
function sage2_1gps {
echo "Digite a senha do usuário root:"
read -s password
remove_ntp_lines # chama a função para remover as linhas existentes
sleep 1.5
# Encontra a linha "server 3.centos.pool.ntp.org iburst" e adiciona as novas linhas logo abaixo
sed -i -r \
-e '/^#*\s*server 3\.centos\.pool\.ntp\.org( iburst)?/a \
server gps1\
peer' /etc/ntp.conf
echo "------------------------------------------------------------------"
echo "As seguintes linhas foram adicionadas com sucesso:"
echo
echo "server gps1"
echo "peer"
echo "------------------------------------------------------------------"
}
export -f sage2_1gps
#-----------------------------------------------------------
# OPÇÃO 19 - Função configurar sincronismo de tempo ntp.conf
#-----------------------------------------------------------
config_ntp() {
while true; do
cd /etc
echo "
Deseja configurar o arquivo sincronismo de tempo ntp.conf padrao CTEEP? <S> <N>:"
read opcao_ntp
case "$opcao_ntp" in

[sS]* )
echo "
Quantos servidores SAGE contempla no projeto de arquitetura de rede?
[1] um
[2] dois
-----------------------------------------------------------------------------
Digite a opção desejada e pressione [ENTER]:"
read num_sage
echo "
Quantos equipamentos GPS contempla no projeto de arquitetura de rede?
[1] um
[2] dois
-----------------------------------------------------------------------------
Digite a opção desejada e pressione [ENTER]:"
read num_gps
echo "
Qual SAGE esta sendo configurado neste momento?
[1] sage1
[2] sage2
-----------------------------------------------------------------------------
Digite a opção desejada e pressione [ENTER]:"
read sage1_2

case "$num_sage" in
"1")
  case "$num_gps" in
  "1")
    case "$sage1_2" in
    "1" | "2")
      sage1_1gps
      ;;
    esac
    ;;
  "2")
    case "$sage1_2" in
    "1" | "2")
      sage1_2gps
      ;;
    esac
    ;;
  esac
  ;;
"2")
  case "$num_gps" in
  "1")
    case "$sage1_2" in
    "1")
      sage1_1gps
      ;;
    "2")
      sage2_1gps
      ;;
    esac
    ;;
  "2")
    case "$sage1_2" in
    "1")
      sage1_2gps
      ;;
    "2")
      sage2_2gps
      ;;
    esac
    ;;
  esac
  ;;
esac

comentar_srv_default
;;

[nN]* )
echo "Configuração interrompida por não confirmação!"
break
;;

*)
echo "
[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:

[CTRL + C] Para sair do script"
;;
esac
done
}
#------------------------------------------------
# OPÇÃO 20 - Função criar e copiar chave pública
#------------------------------------------------
# Função copiar chave pública
copy_ch_public() {
cd $SAGE
while true; do
echo "Gostaria de copiar a chave pública para o outro servidor? <S> <N>:"
read copy_chp
case "$copy_chp" in
[sS]* )
echo "A arquitetura de rede inclui 2 servidores SAGE? <S> <N>:"
read num_servidores
case "$num_servidores" in
[nN]* )
echo "----------------------------------------------------------------------------------"
echo "OBS: A configuração de chave pública não é realizada apenas para um único servidor"
echo "----------------------------------------------------------------------------------"
break
;;
[sS]* )
echo "Os servidores SAGE já possuem acesso mútuo via SSH? <S> <N>:"
read tem_ssh
case "$tem_ssh" in
[nN]* )
echo "-----------------------------------------------------------------------------------"
echo "A cópia foi interrompida devido à falta de acesso mútuo via SSH entre os servidores"
echo "-----------------------------------------------------------------------------------"
break
;;
[sS]* )
dig_name_base
echo "Para qual servidor SAGE você deseja copiar a chave pública?
[1] sage1
[2] sage2
-----------------------------------------------------------------------------
Digite a opção desejada e pressione [ENTER]:"
read sage_destino
case "$sage_destino" in
"1"|"2")
echo "Copiando a chave pública para ${base_nome}-${sage_destino}"
ssh-copy-id sagetr1@"${base_nome}-${sage_destino}"
break
;;
*)
echo "[ERRO] Opção inválida. Tente novamente."
;;
esac
;;
*)
echo "[ERRO] Opção inválida. Tente novamente."
;;
esac
;;
*)
echo "[ERRO] Opção inválida. Tente novamente."
;;
esac
;;
[nN]* )
echo "Copia interrompida por não confirmação!"
break
;;
*)
echo "[ERRO] Opção inválida. Tente novamente."
;;
esac
done
}
export -f copy_ch_public
# Função criar chave publica
cria_ch_public() {
while true; do
cd $SAGE
echo "
Deseja criar a chave pública? <S> <N>:"
read -r criar_chp
case "$criar_chp" in

[sS]* )
echo "Criando chave pública"
ssh-keygen
sleep 0.5
echo "-----------------------------------"
echo "Chave pública criada com sucesso!"
echo
ls -l $HOME/.ssh
echo "-----------------------------------"
cat $HOME/.ssh/id_rsa.pub
echo "-----------------------------------"
copy_ch_public
break
;;

[nN]* )
echo "Instalação interrompida por não confirmação!"
break
;;

*)
echo "
[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:

[CTRL + C] Para sair do script"
;;
esac
done
}
export -f cria_ch_public
#---------------------------------------------------------
# OPÇÃO 21 - Função copiar e habilitar script criabkpsage
#---------------------------------------------------------
copiar_criabkpsage() {
while true; do
cd $SAGE
echo "
Deseja copiar e habilitar o script criabkpsage padrao CTEEP? <S> <N>:"
read copy_bkp
case "$copy_bkp" in

[sS]* )
src="/export/home/sagetr2/sage/padrao_sscl_cteep/sage/criabkpsage"
dest="$SAGE/"

cp "$src" "$dest"
chmod +x "${dest}/criabkpsage"
echo "----------------------------------------------------- "
echo "Arquivo criabkpsage copiado e habilitado com sucesso!"
echo "----------------------------------------------------- "
break
;;

[nN]* )
echo "Instalação interrompida por não confirmação!"
break
;;

*)
echo "
[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:

[CTRL + C] Para sair do script"
;;
esac
done
}
export -f copiar_criabkpsage
#------------------------------------------------------------
# OPÇÃO 22 - Função copiar arqs padrao para o diretorio $IHM
#------------------------------------------------------------
copy_ihm() {
while true; do
echo "
Deseja copiar todos os arquivos padrao CTEEP da pasta IHM? <S> <N>:"
read copy_ihm
case "$copy_ihm" in

[sS]* )
dig_name_base
dir_ihm="$SAGE/config/$xxx/ihm"
cp -r $SAGE/padrao_sscl_cteep/ihm/* "$dir_ihm/"
echo "----------------------- "
echo "Arquivos copiados:"
echo
for file in $SAGE/padrao_sscl_cteep/ihm/*; do
echo "$(basename "$file")"
done
echo "----------------------- "
echo "Arquivo removido:"
echo "SigAnot.csv"
echo "----------------------- "
rm "$dir_ihm/SigAnot.csv"
break
;;

[nN]* )
echo "Copia interrompida por não confirmação!"
break
;;

*)
echo "
[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:

[CTRL + C] Para sair do script"
;;
esac
done
}
export -f copy_ihm
#------------------------------------------------------------------
# OPÇÃO 23 - Função copiar arqs AU som padrao para o diretorio $BD
#------------------------------------------------------------------
copy_bd() {
while true; do
echo "
Deseja copiar todos os arquivos de som (AU) padrao CTEEP? <S> <N>:"
read copy_som
case "$copy_som" in

[sS]* )
dig_name_base
dir_bd="$SAGE/config/$xxx/bd"
cp -r $SAGE/padrao_sscl_cteep/bd/* "$dir_bd/"
echo "------------------------------ "
echo "Arquivos copiados com sucesso:"
echo
for file in $SAGE/padrao_sscl_cteep/bd/*; do
echo "$(basename "$file")"
done
echo "---------------------------- "
break
;;

[nN]* )
echo "Copia interrompida por não confirmação!"
break
;;

*)
echo "
[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:

[CTRL + C] Para sair do script"
;;
esac
done
}
export -f copy_bd
#--------------------------------------------------------------
# OPÇÃO 24 - Função copiar arqs padrao para o diretorio $TELAS
#--------------------------------------------------------------
copy_telas() {
while true; do
echo "
Deseja copiar todos os arquivos padrao CTEEP de telas? <S> <N>:"
read copy_telas
case "$copy_telas" in

[sS]* )
dig_name_base
dir_telas="$SAGE/config/$xxx/telas"
cp -r $SAGE/padrao_sscl_cteep/telas/* "$dir_telas/"
echo "---------------------------- "
echo "Arquivos e pastas copiados:"
echo
for file in $SAGE/padrao_sscl_cteep/telas/*; do
echo "$(basename "$file")"
done
echo "---------------------------- "
break
;;

[nN]* )
echo "Copia interrompida por não confirmação!"
break
;;

*)
echo "
[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:

[CTRL + C] Para sair do script"
;;
esac
done
}
export -f copy_telas
#-----------------------------------------------------------------------
# OPÇÃO 25 - Função copiar arquivo SSC_Amb padrao para o diretorio $SYS
#-----------------------------------------------------------------------
copy_ssc_amb() {
while true; do
echo "
Deseja copiar o arquivo padrao CTEEP SSC_Amb? <S> <N>:"
read copy_sys
case "$copy_sys" in

[sS]* )
dig_name_base
dir_sys="$SAGE/config/$xxx/sys"
cp -r $SAGE/padrao_sscl_cteep/sys/* "$dir_sys/"
echo "---------------------------- "
echo "Arquivo copiado:"
echo
for file in $SAGE/padrao_sscl_cteep/sys/*; do
echo "$(basename "$file")"
done
echo "---------------------------- "
reiniciar_pc
break
;;

[nN]* )
echo "Copia interrompida por não confirmação!"
break
;;

*)
echo "
[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:

[CTRL + C] Para sair do script"
;;
esac
done
}
export -f copy_ssc_amb
#------------------------------------------------------------------------------
# OPÇÃO 26 - Função configurar padrao no arquivo de logs do sistema (logrotate)
#------------------------------------------------------------------------------
conf_logrotate() {
while true; do
cd /etc
echo "
Deseja configurar o arquivo logs de sistema para o padrao CTEEP? <S> <N>:"
read opcao_log
case "$opcao_log" in

[sS]* )
echo "Por favor, insira a senha root:"
read -s password

echo "Alterando atributos no logrotate.conf"
dest_logrotate="/etc/logrotate.conf"

#sudo sed -i 's/rotate\s*4/rotate 24/; s/#compress/compress/' "$dest_logrotate" #versão1.0
sudo sed -i -E 's/^rotate\s+[0-9]+$/rotate 24/; s/#compress/compress/' "$dest_logrotate"
echo "----------------------------------------------------------------------"
echo "Arquivo logs do sistema configurado com sucesso conforme padrao CTEEP!"
echo
echo "Linhas modificadas no logrotate.conf:"
echo
grep -E '^\s*(rotate\s*\s*24|compress)' "$dest_logrotate"
echo "----------------------------------------------------------------------"
break
;;

[nN]* )
echo "Configuracao interrompida por nao confirmacao!"
break
;;

*)
echo "
[ERRO] Opcao invalida. Tente novamente e pressione [ENTER]:

[CTRL + C] Para sair do script"
;;
esac
done
}
export -f conf_logrotate
#----------------------------------------------------------------
# OPÇÃO 27 - Função copiar, descompatar e atualizarBD fria fonte
#----------------------------------------------------------------
extraicnf_aff() {
while true; do
cd $SAGE
echo "
Deseja extrair backup sagecnf? <S> <N>:"
read extrair_cnf
case "$extrair_cnf" in

[sS]* )
dig_name_base
found_file=false
for file in $(ls -1 $SAGE/*"$xxx".tar.* 2> /dev/null | sort -t. -k2,2nr); do
if [ -f "$file" ]; then
zipconfig -x "$file" -C "$SAGE/"
echo "Arquivo $file extraído com sucesso!"
found_file=true
aff
break
fi
done

if [ "$found_file" = false ]; then
for file in $(ls -1 $SAGE/*"$xxx"_*.tar.Z 2> /dev/null); do
if [ -f "$file" ]; then
zipconfig -x "$file" -C "$SAGE/"
echo "Arquivo $file extraído com sucesso!"
found_file=true
aff
break
fi
done
fi
if [ "$found_file" = false ]; then
echo "Nenhum arquivo de backup sagecnf encontrado."
fi
break
;;

[nN]* )
echo "Descompactacao interrompida por nao confirmacao!"
break
;;

*)
echo "
[ERRO] Opcao invalida. Tente novamente e pressione [ENTER]:

[CTRL + C] Para sair do script"
;;
esac
done
}
export -f extraicnf_aff
#-----------------------------------------------------------------
# OPÇÃO 28 - Função copiar dados dats padrao para o #include /sage
#-----------------------------------------------------------------
entidade_dat() {
while true; do
echo "Deseja prosseguir com a configuração das entidades padrão CTEEP? <S> ou <N>"
read config_entidades
case "$config_entidades" in

[nN]* )
echo "Copia das entidades.dat interrompida por nao confirmacao!"
break
;;

[sS]* )
dig_name_base
echo "
--------------------------------------------------------------------------------"
echo "Escolha uma das opções abaixo?"

echo "[1] Criar novo include sage e copiar todas as entidades padrao CTEEP"
echo "[2] Copiar apenas as entidades padrao CTEEP para um include sage existente
--------------------------------------------------------------------------------
Digite a opção desejada e pressione [ENTER]:"
read opcao_entidades
OPCAO_ENTIDADES="${opcao_entidades^^}"

case "$OPCAO_ENTIDADES" in
"1")
echo "Copiando entidades padrao CTEEP para o include sage"
for file in $SAGE/sage/padrao_sscl_cteep/dados/sage/*.dat; do
case $file in
*.dat)
filename=$(basename "$file")
cp "$file" "$SAGE/config/$xxx/bd/dados/sage/$filename"
echo "---------------------"
echo "Arquivos copiados:
$filename"
echo "---------------------"
aff
break
;;
esac
done
;;

"2")
echo "Criando pasta sage em $SAGE/config/$xxx/bd/dados/"
mkdir -p "$SAGE/config/$xxx/bd/dados/sage"
echo "Pasta sage criada com sucesso!"
echo "Iniciando copia das entidades"
cp -r "$SAGE/Arqs_SSCL_CTEEP/dados/sage/" "$SAGE/config/$xxx/bd/dados/sage"
echo "Entidades copiadas com sucesso:"
for file in "$SAGE/Arqs_SSCL_CTEEP/dados/sage/"*.dat; do
echo "$(basename "$file")"
aff
done
break
;;

*)
echo "
[ERRO] Opcao invalida. Tente novamente e pressione [ENTER]:

[CTRL + C] Para sair do script"
;;
esac
;;

*)
echo "
[ERRO] Opcao invalida. Tente novamente e pressione [ENTER]:

[CTRL + C] Para sair do script"
;;
esac
done
}
export -f entidade_dat
#--------------------------------------------------------
# OPÇÃO 29 - Copia e reinstala arquivo calculos.c padrao
#--------------------------------------------------------
copy_calc() {
while true; do
echo "
Deseja copiar e reinstalar o arquivo padrao CTEEP calculos.c? <S> <N>:"
read copiar_calc
case "$copiar_calc" in

[sS]* )
dig_name_base
for file in $SAGE/padrao_sscl_cteep/calculos/*; do
filename=$(basename "$file")
cp -r $SAGE/padrao_sscl_cteep/calculos/ $SAGE/calculos/$xxx
echo "-------------------------------------"
echo "Arquivo copiado:
$file"
echo "-------------------------------------"
done
inst_calc
break
;;

[nN]* )
echo "Copia interrompida por não confirmação!"
break
;;

*)
echo "
[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:

[CTRL + C] Para sair do script"
;;
esac
done
}
export -f copy_calc
#------------------------------------------
# OPCÃO 30 - Função Configuracao SICCP.CNF
#------------------------------------------
siccp_cnf() {
while true; do
cd $LOG
echo "Deseja configurar o protocolo ICCP padrao CTEEP? <S> <N>:"
read resp_siccp
case $resp_siccp in

[sS]* )
echo "Digite a senha do usuário root:"
read -s password
echo "
Info:
Saiba que considerando uma arquitetura client-server, onde o server é o SICCP e client ICCP, toda configuração do SICCP é feita em um único arquivo, denominado siccp.cnf, que deve residir no diretório $LOG:"
if [ ! -f "$LOG/siccp.cnf" ]; then
echo "Erro: Arquivo $LOG/siccp.cnf não encontrado!"
return 1
fi

#Apagando os dados existentes do arquivo
sudo sh -c "> $LOG/siccp.cnf"

#Adicionando os novos dados ao arquivo
sudo "> ID= bojsrv1/AUTO     OPMSK= 102   TOUT= 10    T2V= 0    DSPARC= 1" | sudo tee -a "$LOG/siccp.cnf" > /dev/null
sudo "> ID= bojsrv2/AUTO     OPMSK= 102   TOUT= 10    T2V= 0    DSPARC= 1" | sudo tee -a "$LOG/siccp.cnf" > /dev/null

echo "Arquivo $LOG/siccp.cnf atualizado com sucesso!"
cat $LOG/siccp.cnf
return 0
break
;;

[nN]* )
echo "Configuração interrompida por não confirmação!"
break
;;

* )
echo "[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:"

echo "[CTRL + C] Para sair do script"
;;
esac
done
}
export -f siccp_cnf
#------------------------------------------------------------------
# Parte 31 - Função Configurar bloqueio de Visores usuario e senha
#-----------------------------------------------------------------
# Função remove visor opcao 1
function remove_visores1 {
sed -i '/^\s*{\s*ACAO_AtivarVisorCalculos\s*1\s*PRIV_Supervisor\s*}\s*$/d' $SAGE/config/$xxx/ihm/Licencas.dat
sed -i '/^\s*{\s*ACAO_AtivarVisorBase\s*1\s*PRIV_Supervisor\s*}\s*$/d' $SAGE/config/$xxx/ihm/Licencas.dat
sed -i '/^\s*{\s*ACAO_AtivarEditor\s*1\s*PRIV_Supervisor\s*}\s*$/d' $SAGE/config/$xxx/ihm/Licencas.dat
sed -i '/^\s*{\s*ACAO_AtivarOutros\s*1\s*PRIV_Supervisor\s*}\s*$/d' $SAGE/config/$xxx/ihm/Licencas.dat
echo "------------------------------------------------------------------"
echo "As seguintes linhas foram bloqueadas (removidas):"
echo
echo "{ ACAO_AtivarVisorCalculos          1 PRIV_Supervisor }"
echo "{ ACAO_AtivarVisorBase              1 PRIV_Supervisor }"
echo "{ ACAO_AtivarEditor                 1 PRIV_Supervisor }"
echo "{ ACAO_AtivarOutros                 1 PRIV_Supervisor }"
echo "------------------------------------------------------------------"
}
export -f remove_visores1
# Função remove visor opcao 2
function remove_visores2 {
sed -i '/^\s*{\s*ACAO_AtivarVisorCalculos\s*1\s*PRIV_Supervisor\s*}\s*$/d' $SAGE/config/$xxx/ihm/Licencas.dat
sed -i '/^\s*{\s*ACAO_AtivarVisorBase\s*1\s*PRIV_Supervisor\s*}\s*$/d' $SAGE/config/$xxx/ihm/Licencas.dat
sed -i '/^\s*{\s*ACAO_AtivarOutros\s*1\s*PRIV_Supervisor\s*}\s*$/d' $SAGE/config/$xxx/ihm/Licencas.dat
echo "------------------------------------------------------------------"
echo "As seguintes linhas foram bloqueadas (removidas):"
echo
echo "{ ACAO_AtivarVisorCalculos          1 PRIV_Supervisor }"
echo "{ ACAO_AtivarVisorBase              1 PRIV_Supervisor }"
echo "{ ACAO_AtivarOutros                 1 PRIV_Supervisor }"
echo "------------------------------------------------------------------"
}
export -f remove_visores2
# Função 31
licencas_dats() {
while true; do
echo "
Deseja configurar nesse momento o bloqueio de visores de usuário e senha no arquivo licenca.dat padrao CTEEP? <S> <N>:"
read block_visores
case "$block_visores" in

[sS]* )
echo "------------------------------------------------------------------------------------------------------------
Essa etapa bloqueia os seguintes visores:
Visor de Calculos
Visor de Base
Editor
Outros

INFO:
Se foi finalizado todo o TAC e não terá outras etapas, escolha a opção (1).
Se o TAC esta em andamento, escolha a opção (2), se não você não terá mais acesso ao Visor de Edição Sigdraw.
Caso desejar fazer essa etapa no final do TAC, escolha a opção (3).

Escolha uma das opções abaixo:

[1] Bloquear todos
[2] Manter o Editor e bloquear os demais
[3] Sair, fazer em outro momento
----------------------------------------------------------------------------------------------------------------
Digite a opção desejada e pressione [ENTER]:"
read opcao_bloqueios

case "$opcao_bloqueios" in
"1")
dig_name_base
remove_visores1
break
;;

"2")
dig_name_base
remove_visores2
break
;;

"3")
echo "Farei essa etapa em outro momento!"
break
;;
esac
;;

[nN]* )
echo "Copia interrompida por não confirmação!"
break
;;

*)
echo "
[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:

[CTRL + C] Para sair do script"
;;
esac
done
}
export -f licencas_dats
#------------------------------------------------------------------------------------------------------
# Parte 1 - Função Modifica senhas - cria base - config hostname e hosts - inst licença - habilita base
#------------------------------------------------------------------------------------------------------
completo_parte1() {
while true; do
echo "
Deseja prosseguir com a instalação integral parte 1? <S> <N>:"
read completo_parte1
case "$completo_parte1" in

[sS]* )
alterar_senhas
criar_base_nova
alterar_hostname
conf_hosts
inst_lic
habilitar_base
reiniciar_pc
break
;;

[nN]* )
echo "Instalação integral - parte 1 interrompida por não confirmação!"
break
;;

*)
echo "
[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:

[CTRL + C] Para sair do script"
;;
esac
done
}
export -f completo_parte1
#-----------------------------------------------------------------------------------------------------------------------------------------------
# Parte 2 - Função copia e extrai sagecnf - habilita postgres - copia e instala calc e driver mms - copia dats, cria include sage - AtualizaBD)
#-----------------------------------------------------------------------------------------------------------------------------------------------
completo_parte2() {
while true; do
echo "
Deseja prosseguir com a instalação integral parte 2? <S> <N>:"
read completo_parte2
case "$completo_parte2" in

[sS]* )
copia_bkp_sagecnf
extraicnf_aff
habilitar_postgres
copy_calc
inst_mms
entidade_dat
reiniciar_pc
break
;;

[nN]* )
echo "Instalação integral - parte 2 interrompida por não confirmação!"
break
;;

*)
echo "
[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:

[CTRL + C] Para sair do script"
;;
esac
done
}
export -f completo_parte2
#---------------------------------------------------------------
# Parte 3 - Função instala update - patchs - tz horario de verão
#---------------------------------------------------------------
completo_parte3() {
while true; do
echo "
Deseja prosseguir com a instalação integral parte 3? <S> <N>:"
read completo_parte3
case "$completo_parte3" in

[sS]* )
inst_upd
inst_ptc
inst_tz
break
;;

[nN]* )
echo "Instalação integral - parte 3 interrompida por não confirmação!"
break
;;

*)
echo "
[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:

[CTRL + C] Para sair do script"
;;
esac
done
}
export -f completo_parte3
#-------------------------------------------------------------------------------------------------------------
# Parte 4 - Função configura interfaces de rede dc - bonding - aquisição - distribuição e protocolo siccp.cnf
#-------------------------------------------------------------------------------------------------------------
completo_parte4() {
while true; do
echo "
Deseja prosseguir com a instalação integral parte 4? <S> <N>:"
read completo_parte4
case "$completo_parte4" in

[sS]* )
rede_dc
rede_bond
rede_rele
rede_boj
rede_cav
siccp_cnf
break
;;

[nN]* )
echo "Instalação integral - parte 4 interrompida por não confirmação!"
break
;;

*)
echo "
[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:

[CTRL + C] Para sair do script"
;;
esac
done
}
export -f completo_parte4
#---------------------------------------------------------------------------------------------------------------------------------
# Parte 5 - Função contigura NTP - cssagerc - chave publica - lorotate - criabkpsage - copia arqs padrao no ihm, bd, telas e sys
#----------------------------------------------------------------------------------------------------------------------------------
completo_parte5() {
while true; do
echo "
Deseja prosseguir com a instalação integral parte 5? <S> <N>:"
read completo_parte5
case "$completo_parte5" in

[sS]* )
config_ntp
conf_cssagerc
cria_ch_public
conf_logrotate
copiar_criabkpsage
licencas_dats
copy_ihm
copy_bd
copy_telas
aff
copy_ssc_amb
break
;;

[nN]* )
echo "Instalação integral - parte 5 interrompida por não confirmação!"
break
;;

*)
echo "
[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:

[CTRL + C] Para sair do script"
;;
esac
done
}
export -f completo_parte5
######################################################################
# Funções de instalação integral
######################################################################
instalacao_integral() {
clear_on
while true; do
echo "
===================================================================================================================================================================
Instalação e configuração integral do SSCL Padrão Isa CTEEP
    
O que deseja?
    
[  1 ] Instalacao integral - parte 1 (Modifica senhas - cria base - config hostname e hosts - inst licença - habilita base)
[  2 ] Instalacao integral - parte 2 (Copia e extrai sagecnf - habilita postgres - copia e instala calc e driver mms - copia dats, cria include sage - AtualizaBD)
[  3 ] Instalacao integral - parte 3 (Instala update - patchs - tz horario de verão)
[  4 ] Instalacao integral - parte 4 (Configura interfaces de rede dc - bonding - aquisição - distribuição e protocolo siccp.cnf)
[  5 ] Instalacao integral - parte 5 (Contigura NTP - cssagerc - chave publica - logrotate - criabkpsage - bloq visores - arqs padrao do ihm, bd, telas e sys) 
[ 90 ] Retornar ao menu inicial
[ 99 ] Sair do script
===================================================================================================================================================================
Digite a opção desejada e pressione [ENTER]:"
read escolha_integral
case $escolha_integral in

"1") completo_parte1
break
;;
"2") completo_parte2
break
;;
"3") completo_parte3
break
;;
"4") completo_parte4
break
;;
"5") completo_parte5
break
;;
"90")
exibir_menu
break
;;

"99")
echo "Saimos do script ok!"
exit 0
;;

*)
echo "
[ERRO] Opcao invalida. Tente novamente e pressione [ENTER]:

[CTRL + C] Para sair do script"
;;
esac
done
}
export -f instalacao_integral
#########################################################################
# Funções de instalação seletiva
#########################################################################
instalacao_seletiva() {
clear_on
while true; do
echo "
==========================================================================
Instalação e configuração seletiva do SSCL Padrão Isa CTEEP
	
O que deseja?

[  1 ] Modificar senhas do usuario e root super-usuario
[  2 ] Criar base e copiar backup sagecnf
[  3 ] Configurar hostname da máquina
[  4 ] Habilitar base
[  5 ] Habilitar postgres
[  6 ] Instalar calculos
[  7 ] Instalar driver MMS
[  8 ] Instalar licença SAGE
[  9 ] Instalar update
[ 10 ] Instalar patchs
[ 11 ] Instalar tz horario de verao
[ 12 ] Configurar comandos de atalho no arquivo cssagerc
[ 13 ] Configurar o hosts
[ 14 ] Configurar interface de rede da difusao confiavel
[ 15 ] Criar e configurar interface de rede logica Bonding
[ 16 ] Configurar interface de rede de aquisicao 61850
[ 17 ] Configurar interface de rede de distribuicao para BOJ
[ 18 ] Configurar interface de rede de distribuicao para CAV
[ 19 ] Configurar sincronismo de tempo NTP
[ 20 ] Configurar chave publica
[ 21 ] Copiar e habilitar o script padrao de backup criabkpsage
[ 22 ] Copiar todos arqs padrao para diretorio IHM
[ 23 ] Copiar todos arqs som.au padrao para diretorio BD
[ 24 ] Copiar todos arqs padrao para diretorio TELAS
[ 25 ] Copiar o arquivo padrao SSC_Amb para diretorio SYS
[ 26 ] Configurar arquivo de logs do sistema
[ 27 ] Extrai backup sagecnf e AtualizarBD fria fonte
[ 28 ] Copiar todos arqs dats padrao para a pasta dados include sage
[ 29 ] Copiar e instalar o arquivo calculos.c padrao
[ 30 ] Configurar protocolo SICCP arquivo siccp.cnf
[ 31 ] Fim do TAC - Configurar bloqueio de Visores no Licenca.dat
[ 90 ] Retornar ao menu inicial
[ 99 ] Sair do script
==========================================================================
Digite a opção desejada e pressione [ENTER]:"

read escolha_seletiva
case $escolha_seletiva in

"1") alterar_senhas
break
;;
"2") criar_base_nova
break
;;
"3") alterar_hostname
break
;;
"4") habilitar_base
break
;;
"5") habilitar_postgres
break
;;
"6") inst_calc
break
;;
"7") inst_mms
break
;;
"8") inst_lic
break
;;
"9") inst_upd
break
;;
"10") inst_ptc
break
;;
"11") inst_tz
break
;;
"12") conf_cssagerc
break
;;
"13") conf_hosts
break
;;
"14") rede_dc
break
;;
"15") rede_bond
break
;;
"16") rede_rele
break
;;
"17") rede_boj
break
;;
"18") rede_cav
break
;;
"19") config_ntp
break
;;
"20") cria_ch_public
break
;;
"21") copiar_criabkpsage
break
;;
"22") copy_ihm
break
;;
"23") copy_bd
break
;;
"24") copy_telas
break
;;
"25") copy_ssc_amb
break
;;
"26") conf_logrotate
break
;;
"27") extraicnf_aff
break
;;
"28") entidade_dat
break
;;
"29") copy_calc
break
;;
"30") siccp_cnf
break
;;
"31") licencas_dats
break
;;
"90")
exibir_menu
break
;;
"99")
echo "
Saimos do script ok!"
exit 0
;;
*)
echo "
[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:

[CTRL + C] Para sair do script"
;;
esac
done
}
export -f instalacao_seletiva

#######################################################################
# Entrar como root e executar todas as configurações uma única vez
#######################################################################
#executar_configuracoes() {
#conf_hosts
#gps_hosts
#hosts_switches
#hosts_redbox
#hosts_ts
#hosts_ieds
#aplicar_hosts_data
#}
#echo "Digite a senha do usuário root para continuar:"
#su root -c "$(declare -f conf_hosts gps_hosts hosts_switches hosts_redbox hosts_ts hosts_ieds executar_configuracoes); executar_configuracoes"

############################
# Funções de Testes TAF/TAC
############################
testes_taf_tac() {
clear_on
while true; do
echo "
Estes testes foram desenvolvidos por Décio Tomasulo De Vicente, da Isa CTEEP, compartilhado e autorizado pelo mesmo para o uso neste script!

Escolha qual teste deseja?

[ 1 ] Instruções - LEIA-ME
[ 2 ] Atualiza Tudo
[ 3 ] Varrer hosts
[ 4 ] Pontos não testados
[ 5 ] Sair
-----------------------------------------------------------------------------
Digite a opção desejada e pressione [ENTER]:"

read escola_testes
case "$escola_testes" in

"1")
echo " =====================================================================================================================
[ 2 ] Atualiza Tudo:

QUAL A FUNÇÃO DESSA OPÇÃO?

1. Executa o comando habilita_base.
2. Desativa os SAGEs e aguarda confirmação do usuário.
3. Realiza uma atualização fria da base de dados.
4. Pergunta ao usuário se a base de dados foi compilada com sucesso.
5. Sincroniza diretórios entre dois servidores.
6. Ativa o gcd nos servidores.
7. Exibe lembretes para o usuário.

Resumo:
Agiliza o processo de desativar os SAGEs, atualizar a base, sincronizar $BD e $TELAS e ativar os SAGEs nos 2 servidores.

INSTRUÇÕES IMPORTANTES ANTES DE RODAR ESSE TESTE:

1. Deve ser executado o habilita_base nos dois servidores para aparecer as linhas abaixo (inclui servidores em .rhosts):

Incluindo site xxxx-sage1 em /export/home/sagetr1/.rhosts.
Incluindo site xxxx-sage2 em /export/home/sagetr1/.rhosts.

2. Os nomes dos servidores deve estar declarado no arquivo hosts conforme padrao ISA CTEEP:
10.10.10.11         xxxx-sage1   
10.10.10.12         xxxx-sage2

3. A rede de difusão deve estar operacional.

4. As chaves publicas e privadas devem estar criadas e funcionais.

=============================================================================================================================
[ 3 ] Varrer hosts:

QUAL A FUNÇÃO DESSA OPÇÃO?

1. O código inicia removendo alguns arquivos previamente criados com rm -rf;
2. Em seguida, é adicionada uma linha de data e hora e a informação de quem criou o script no arquivo arquivo_varredura;
3. O código busca os IPs presentes no arquivo /etc/hosts e os armazena em ip_hosts;
4. Um loop é iniciado para cada IP encontrado em ip_hosts;
5. O comando ping é executado para o IP atual, com um tempo limite de 1 segundo e apenas 1 pacote enviado;
6. Se o comando ping retornar sucesso (valor de retorno igual a 0), a mensagem "******* pingou $ip !!!" é adicionada no arquivo arquivo_varredura e o IP é adicionado ao arquivo ping_ok;
7. Se o comando ping retornar falha (valor de retorno diferente de 0), a mensagem "... não pingou $ip ..." é adicionada no arquivo arquivo_varredura e o IP é adicionado ao arquivo ping_nok;
8. No final, é exibida uma lista dos equipamentos que não pingaram, buscando as informações do /etc/hosts;
9. O código encerra informando onde encontrar os resultados e chamando a função pos_opcoes.

Resumo:
Realiza testes de ping em todos IPs declarados no arquivo hosts e presenta o resultado no arquivo $SAGE/arquivo_varredura dos equipamentos que não pingaram.

=============================================================================================================================
[ 4 ] Pontos não testados:

QUAL A FUNÇÃO DESSA OPÇÃO?

1. A função verifica se foi passado um argumento na linha de comando e define o diretório a ser utilizado para procurar os arquivos com base nesse argumento, caso contrário, utiliza o diretório padrão.
2. A função remove três diretórios, um para armazenar os IDs encontrados, um para armazenar os pontos testados e outro para armazenar os pontos não testados.
3. A função procura todos os IDs dos arquivos pds.dat e remove o caractere de retorno para deixar o arquivo padrão UNIX.
4. A função procura cada ID da pds.dat nos arquivos de alarmes (.alr e .sde no diretório $ARQS) e armazena os pontos testados e não testados.
5. A função exibe os pontos não testados, o total de pontos não testados e indica que a operação foi concluída.

Resumo:
Faz um check de alarmes e eventos e apresenta o resultado no arquivo $SAGE/nao_testados dos pontos não testados

============================================================================================================================="
read -p "Pressione qualquer tecla para voltar ao menu anterior..."
;;

"2")
echo ""
echo "Iniciando atualização total nos 2 servidores"
echo ""
# Corrigindo comando rsh para ssh nos scripts do CEPEL (rsh foi removido a partir do SAGE 28)
# Medida provisoria ate o CEPEL atualizar esses comandos conforme informado pelo suporte.sage@cepel.br
cd $SAGE
sed -i 's/rsh/ssh/g' bin/sys/ativasage
sed -i 's/rsh/ssh/g' bin/sys/desativasage
sed -i 's/rsh/ssh/g' bin/sys/desativasage

habilita_base 

echo ""
echo "Desativando o gcd nos servidores..."
echo ""
desativasage -s

while true; do
echo -n "Se a desativacao dos SAGEs foi cancelada, pressione [N]ao para parar o script ou [S]im para continuar: "
read -r RESP0
echo ""
echo ""
if [[ "$RESP0" != "s" && "$RESP0" != "S" && "$RESP0" != "n" && "$RESP0" != "N" ]]; then
echo "Resposta invalida, entre com s, S, ou n, N."
echo ""
elif [[ "$RESP0" == "n" || "$RESP0" == "N" ]]; then
echo "Operacao cancelada, terminando o script."
echo ""
exit
else
break
fi
done

echo "Aguardando alguns segundos para desativacao completa do gcd nos dois servidores..."
sleep 15

echo ""
echo "Iniciando AtualizaBD fria fonte neste servidor..."
echo ""

AtualizaBD fria fonte 

echo ""
sleep 2

while true; do
echo -n "Se a base compilou com sucesso, pressione [S]im para continuar e [N]ao para parar o script: "
read -r RESP
echo ""
echo ""
if [[ "$RESP" != "s" && "$RESP" != "S" && "$RESP" != "n" && "$RESP" != "N" ]]; then
echo "Resposta invalida, entre com s, S, ou n, N."
echo ""
elif [[ "$RESP" == "n" || "$RESP" == "N" ]]; then
echo "Operacao cancelada, terminando o script."
echo ""
exit
else
break
fi
done

SERVIDOR=$(hostname | rev | cut -c2- | rev)
SERVN=$(hostname | rev | cut -c-1 | rev)

if [[ $SERVN == "1" ]]; then
SERVIDORN="${SERVIDOR}2"
else            
SERVIDORN="${SERVIDOR}1"
exit
fi

HOSTNAME=$(hostname)

echo ""
echo "Sincronizando os arquivos dos diretorios BD e TELAS do $HOSTNAME para o $SERVIDORN..."
echo ""

rsync -az $BD "$SERVIDORN":$SAGE/config/$BASE
rsync -az $TELAS "$SERVIDORN":$SAGE/config/$BASE

echo "Servidores sincronizados com sucesso !"
sleep 2
echo ""
echo "Ativando o gcd nos servidores..."
echo ""
ativasage -s
echo ""
echo "Fim da atualização de base e telas e ativacao do gcd nos dos 2 servidores!"
echo ""
echo "LEMBRE-SE DE NO FINAL DO DIA ATUALIZAR TODO O SAGE UTILIZANDO O SCRIPT 'criasagecnf' E DESCOMPACTANDO NO OUTRO"
break
;;

"3")
echo ""
echo " Iniciando ping em todos IPs do arquivo hosts ... "
echo ""

rm -rf $SAGE/ip_hosts
rm -rf $SAGE/arquivo_varredura
rm -rf $SAGE/ping_ok
rm -rf $SAGE/ping_nok

echo "Data e Horario:`date`" >> $SAGE/arquivo_varredura
echo "Script criado por Decio Tomasulo De Vicente" >> $SAGE/arquivo_varredura
echo "" >> $SAGE/arquivo_varredura

cat /etc/hosts | grep -Eo '([0-9]*\.){3}[0-9]*' >> ip_hosts

lista=`cat ip_hosts`

for ip in $lista

do
ping $ip -c 1 -t 1 &> /dev/null

if [ $? = 0 ]; then
echo "******* pingou $ip !!!" >> $SAGE/arquivo_varredura
echo "$ip" >> $SAGE/ping_ok
else 
echo "... não pingou $ip ..." >> $SAGE/arquivo_varredura
echo "$ip" >> $SAGE/ping_nok
fi
done

echo ""
echo " Mostrando equipamentos que não pingaram:"
echo ""

cat $SAGE/ping_nok | while read linha; do 

grep -w $linha /etc/hosts

done
	
echo ""
echo "Fim !"
echo ""
echo "Para ver todos os resultados, acesso arquivo_varredura "
echo ""
break
;;

"4")
echo ""
echo "Iniciando verificação de pontos testados e não testados"
echo ""
if ($1 = "") then
dir="$BD/dados"
else
dir="$BD/dados/$1"
fi

clear

echo ""
echo " Iniciando check de alarmes (*.alr) e eventos (*.sde) com os pontos na base de dados (pds.dat) "
echo ""
echo " Pesquisando no diretório $dir" 
echo ""

rm -rf $SAGE/ids
rm -rf $SAGE/nao_testados
rm -rf $SAGE/testados

echo "Data e Horario:`date`" >> $SAGE/testados
echo "Data e Horario:`date`" 
echo "Script criado por Decio Tomasulo De Vicente" >> $SAGE/testados
echo "Script criado por Decio Tomasulo De Vicente" 
echo "" >> $SAGE/testados
echo "" >> $SAGE/nao_testados

# Pesquisa todos os IDs dos arquivos pds.dat 
find $dir -type f -name pds.dat | xargs awk -F "=" '/^ID/ {print $2}' | sed 's/ //g' | sed 's/\t//g' > id

# Remove o caractere de return para deixar o arquivo padrao UNIX
tr -d '\r' < id > ids
rm -rf id

# Procura cada ID da pds.dat nos arquivos de alarmes (.alr no diretorio $ARQS) 
while IFS= read -r pnt

do
if grep "$pnt" "$ARQS"/*.alr "$ARQS"/*.sde > /dev/null 
then
echo "$pnt" >> testados 
else
echo "$pnt" >> nao_testados
fi
done < ids 
echo ""
echo " Mostrando pontos não testados:"

more $SAGE/nao_testados

echo ""
echo "Total de pontos não testados:"
wc -l nao_testados 

echo ""
echo "Fim !"
echo ""
echo "Para ver todos os IDs dos pontos, acesso o arquivo nao_testados"
echo ""
break
;;

"5")
pos_opcoes
break
;;

*)
echo "
[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:

[CTRL + C] Para sair do script"
;;
esac
done
}
############################################
# Funções de Restaurar Arquivos Padrão CEPEL
############################################
padrao_cepel() {
while true; do
echo "
Escolha qual arquivo deseja voltar para o padrão CEPEL?
	
[ 1  ] ntp.conf
[ 2  ] logrotate.conf
[ 3  ] cssagerc (oculto)
[ 4  ] calculos.c (demo_ems)
[ 5  ] SSC_Amb (demo_ems)
[ 6  ] dir ihm (demo_ems)
[ 7  ] dir telas (demo_ems)
[ 8  ] som.au (demo_ems)
[ 9  ] dir dados entidades.dats (demo_ems)
[ 10 ] habilita base demo_ems
[ 99 ] Sair
-----------------------------------------------------------------------------
Digite a opção desejada e pressione [ENTER]:"
read arquivo_cepel
case $arquivo_cepel in

"1")
echo "Digite a senha do usuário root:"
su root -c "
cp /etc/ntp.conf /etc/ntp.conf.bak
echo 'Configurando o arquivo ntp.conf para o padrão CEPEL'
sed -i 's/^#\(server [0-3]\.centos\.pool\.ntp\.org iburst\)/\1/' /etc/ntp.conf
sed -i '/^server 127\.127\.1\.0/d' /etc/ntp.conf
sed -i '/^fudge 127\.127\.1\.0 stratum 10/d' /etc/ntp.conf
sed -i '/^server gps1/d' /etc/ntp.conf
sed -i '/^server gps2/d' /etc/ntp.conf
sed -i '/^peer/d' /etc/ntp.conf
echo '------------------------------------------------------------------'
echo 'Linhas alteradas e removidas para default CEPEL do arquivo ntp.conf:'
echo 'DE:'
diff /etc/ntp.conf.bak /etc/ntp.conf | grep '<'
echo 'PARA:'
diff /etc/ntp.conf.bak /etc/ntp.conf | grep '>'
"
echo "------------------------------------------------------------------"
pos_opcoes
break
;;

"2")
echo "Digite a senha do usuário root:"
su root -c "
cp /etc/logrotate.conf /etc/logrotate.conf.bak
echo 'Configurando o log de sistema logrorate.conf para o padrão CEPEL'
sed -i -E 's/^rotate\s+[0-9]+$/rotate 4/; s/^\s*compress/#compress/' /etc/logrotate.conf
echo "------------------------------------------------------------------"
echo 'Linhas alteradas para default CEPEL no logrotate.conf:'
echo 'DE:'
diff /etc/logrotate.conf.bak /etc/logrotate.conf | grep '<'
echo 'PARA:'
diff /etc/logrotate.conf.bak /etc/logrotate.conf | grep '>'
"
echo "------------------------------------------------------------------"
pos_opcoes
break
;;

"3")
echo "
Configurando os comandos de atalho do arquivo cssagerc para o padrão CEPEL"
dest_cssagerc="$SAGE/.cssagerc"
temp_file=$(mktemp -u)

# Verifica se existem linhas a serem removidas
if grep -qE '^\s{4}(# Aliases PADRÃO CTEEP|alias on|alias off|alias aff|alias daa|alias erro|alias extra)' "$dest_cssagerc"; then
# Remove as linhas e redireciona a saída para o arquivo temporário
sed -E '/^    # Aliases PADRÃO CTEEP|^    alias (on|off|aff|daa|erro|extra)/!d' "$dest_cssagerc" > "$temp_file"
sed -i -E '/^    # Aliases PADRÃO CTEEP|^    alias (on|off|aff|daa|erro|extra)/d' "$dest_cssagerc"

# Exibe as linhas removidas
if [ -s "$temp_file" ]; then
echo "--------------------------------------------------------------------------------------------------------"
echo "Linhas de comando fora do padrao CEPEL removidas:"
echo
cat "$temp_file"
echo "--------------------------------------------------------------------------------------------------------"
fi
  
else
# Encerra o script caso não existam linhas a serem removidas
echo "Não foram encontradas linhas fora do padrao CEPEL para remoção."
fi

# Restaurar linhas existentes
sed -i '79s/\(set history\s*=\s*\)[0-9]\+/\140/; 80s/\(set savehist\s*=\s*\)[0-9]\+/\140/' "$dest_cssagerc"

# Exibe as linhas alteradas
echo "Linhas alteradas para o padrão CEPEL:"
echo
grep -E '^\s{4}(set history|set savehist)' "$dest_cssagerc"
echo "--------------------------------------------------------------------------------------------------------"
break
;;

"4")
dig_name_base
echo "
Configurando o arquivo calculos.c da sua base para o padrao demo_ems"
dir_calc_demo="$SAGE/calculos/$xxx"
cp -r $SAGE/calculos/demo_ems/calculos.c "$dir_calc_demo"
echo "----------------------------------------------------- "
echo "Alterado o calculos.c da sua base para o padrão CEPEL"
echo
cat "$SAGE/calculos/$xxx/calculos.c"
echo "----------------------------------------------------- "
inst_calc
break
;;

"5")
echo "
Configurando o arquivo SSC_Amb da sua base para o padrao demo_ems"
dig_name_base
dir_sys="$SAGE/config/$xxx/sys"
cp -r $SAGE/config/demo_ems/sys/SSC_Amb "$dir_sys/"
echo "------------------------------------------------------------- "
echo "Alterado o SSC_Amb da sua base alterado para o padrao demo_ems"
echo
cat "$SAGE/config/$xxx/sys/SSC_Amb"
echo "------------------------------------------------------------- "
reiniciar_pc
break
;;

"6")
echo "
Configurando diretorio ihm da sua base para o padrao demo_ems"
dig_name_base
dir_ihm="$SAGE/config/$xxx/ihm"
rm -rf "$dir_ihm"
cp -r $SAGE/config/demo_ems/ihm "$dir_ihm/"
echo "------------------------------------------------------------ "
echo "Alterado o ihm da sua base modificado para o padrao demo_ems"
echo
for file in "$dir_ihm"/*; do
echo "$(basename "$file")"
done
echo "---------------------------------------------------------------- "
break
;;

"7")
echo "
Configurando diretorio telas da sua base para o padrao demo_ems"
dig_name_base
dir_telas="$SAGE/config/$xxx/telas"
rm -rf "$dir_telas"
cp -r $SAGE/config/demo_ems/telas "$dir_telas/"
echo "-------------------------------------------------------------- "
echo "Alterado as telas da sua base modificado para o padrao demo_ems"
echo
for file in "$dir_telas"/*; do
echo "$(basename "$file")"
done
echo "---------------------------------------------------------------- "
break
;;

"8")
echo "
Configurando todos os arquivos de som.au da sua base para o padrao demo_ems"
dig_name_base
dir_som="$SAGE/config/$xxx/bd"
find "$dir_som" -type f -name '*.au' -delete
cp -r $SAGE/config/demo_ems/bd/*.au "$dir_som/"
echo "--------------------------------------------------------------- "
echo "Arquivos de som.au da sua base modificado para o padrao demo_ems"
echo
for file in "$dir_som"/*.au; do
echo "$(basename "$file")"
done
echo "---------------------------------------------------------------- "
break
;;

"9")
echo "
Configurando o diretório dados das entidades.dats da sua base para o padrao demo_ems"
dig_name_base
dir_dados="$SAGE/config/$xxx/bd/dados"
rm -rf "$dir_dados"
cp -r $SAGE/config/demo_ems/bd/dados "$dir_dados/"
echo "-------------------------------------------------------------------- "
echo "Alterado o dados das entidades.dats da sua base para o padrao demo_ems"
echo
for file in "$dir_dados"/*; do
echo "$(basename "$file")"
done
echo "-------------------------------------------------------------------- "
aff
break
;;

"10")
echo "
Habilitando a base demo_ems"
cd $SAGE
habilita_base demo_ems
sleep 2
echo "--------------------------------------
Base habilitada com sucesso!"
cd $SAGE base demo_ems
sleep 2
var
echo "--------------------------------------"
reiniciar_pc
break
;;

"99")
exit 0
;;

*)
echo "
[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:

[CTRL + C] Para sair do script"
;;
esac
done
}
export -f padrao_cepel
######################
# Funções Informacoes
######################
informacoes() {
clear_on
while true; do
echo "
-----------------------------------------------------------------------------
O que deseja?
	
[ 1 ] Contato
[ 2 ] Instruções
[ 3 ] Dicas
[ 4 ] Atualizacoes do script
[ 5 ] Sair
-----------------------------------------------------------------------------
Digite a opção desejada e pressione [ENTER]:"

read opcoes_info
case $opcoes_info in

"1") 
echo "==================================================================================
Script criado por:

Jose Eduardo da Neiva Oliveira
E-mail: dudufrontmg@hotmail.com
WhatsApp | Telegram: +55 34 99229-4170
Linkedin: jnoliveira 

Fique à vontade para enviar sugestões de aprimoramento, tirar dúvidas, reportar erros identificados, pedir conselhos e compartilhar elogios!
"
echo "=================================================================================="
read -p "Pressione qualquer tecla para voltar ao menu anterior..."
;;

"2") 
echo "==================================================================================
Antes de iniciar as configuracoes, seguir o basico do basico:

1. Nas sub pastas já estão os últimos arquivos padrão SSCL conforme o sharepoint da ISA CTEEP.

2. Sempre verificar no sharepoint ou diretamente com o cliente se possui alguma nova atualização dos arquivos.

3. Caso possuir, adicionar na sub pasta sage os seguintes arquivos:
   3.1 backup sagecnf (pode ser tanto o tar.bz2 quanto o tar.Z que o script reconhece e extrai qualquer um desses formatos, priorizando sempre o bz2 caso houver os 2 dentro da pasta)
   3.2 arquivo de licença do SAGE
   3.3 path_instala_tz (de acordo com a versão do SAGE)
   3.4 update (caso necessário)
   3.5 patches (caso necessário)

4.Fazer os backups dos arquivos default CEPEL e adicionar na sub pasta /padrao_sscl_cteep/arqs_default_cepel/
Exemplo dos arquivos: /padrao_sscl_cteep/arqs_default_cepel/CentOS_7x/
cssagerc
logrotate.conf
ntp.conf
Aos demais arquivos, não necessita possui na base demo_ems!

5. Para fazer a instação integral necessita ter todos esses arquivos acima informados nas suas respectivas pastas.

6. Além dos arquivos, também necessita saber ou ter todas as informações necessarias, tais como:
Lista de IPs
Arquitetura de Rede
Protocolo de distribuição (ICCP ou i104).
"
echo "=================================================================================="
read -p "Pressione qualquer tecla para voltar ao menu anterior..."
;;

"3")
echo "==================================================================================

1. Copiar a pasta padrao_SSCL_CTEEP e colar dentro do $SAGE
2. Abrir o terminal
3. cd $SAGE/padrao_sscl_cteep/
4. chmod +x conf_sscl_cteep.sh
5. conf_sscl_cteep.sh [ENTER]

Seja Bem-vindo ao script!
"
echo "=================================================================================="
read -p "Pressione qualquer tecla para voltar ao menu anterior..."
;;

"4")
echo "=============================================================
Título: Instalação e Configuração Padrão SSCL Isa CTEEP
Autor: José Eduardo da Neiva Oliveira
Data inicial do desenvolvimento: 22/03/2023
Versão: 1.0
Descrição: Este script realiza a instalação e configuração padrão do SSCL da empresa Isa CTEEP para CentOS x SAGE.
Uso: ./conf_sscl_cteep.sh

Finalizado e Testado
Data: 14/04/2023
Versão: 1.0 
Descrição: Os testes foram realizados via VM não sendo o suficiente para uma homologação 100% funcional do script.

Atualizações
Data: 18/04/2023
Versão: 1.1
Descrição:
[  1 ] Modificar senhas do usuario e root super-usuario
Antes - Informava com mensagem de senha alterada com sucesso mesmo digitando a senha root incorretamente.
Agora - Não informa a mensagem de senha alterada com sucesso ao digitar a senha root incorretamente.

[ 12 ] Configurar comandos de atalho no arquivo cssagerc:
Antes - Substituia apenas o valor default = 40 dos atributos set history e set savehist para 1000.
Agora - Substitui qualquer valor numérico existente nos atributos set history e set savehist para 1000.

[ 26 ] Configurar arquivo de logs do sistema:
Antes - Substituia apenas o valor default = 4 do atributo rotate 24.
Agora - Substitui qualquer valor numérico existente no atributo rotate para 24.
"
echo "============================================================="
read -p "Pressione qualquer tecla para voltar ao menu anterior..."
;;

"5")
pos_opcoes
break
;;

*)
echo "
[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:

[CTRL + C] Para sair do script"
;;
esac
done
}
#########################################################################
# Função para exibir o menu de acesso
#########################################################################
exibir_menu() {
clear_on
while true; do
echo "
-----------------------------------------------------------------------------
****** Bem-vindo ao Instalador e Configurador do SSCL Padrão Isa CTEEP ******
-----------------------------------------------------------------------------
                                Menu de Acesso
O que deseja?
  
[  1 ] Instalação e configuração integral do SSCL
[  2 ] Instalação e configuração seletiva do SSCL
[  3 ] Testes para TAF/TAC
[  4 ] Restaurar padrão CEPEL
[  5 ] Informações
[ 99 ] Sair
-----------------------------------------------------------------------------
Digite a opção desejada e pressione [ENTER]:"

read escolha
case $escolha in
"1")
instalacao_integral
break
;;
"2")
instalacao_seletiva
break
;;
"3")
testes_taf_tac
break
;;
"4")
padrao_cepel
break
;;
"5")
informacoes
break
;;
"99")
echo "
Saimos do script ok!"
exit 0
;;
*)
echo "
[ERRO] Opção inválida. Tente novamente e pressione [ENTER]:

[CTRL + C] Para sair do script"
;;
esac
done
}
export -f exibir_menu
exibir_menu