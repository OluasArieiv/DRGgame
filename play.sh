#!/bin/bash

# ========= GERENCIADOR DE MÚLTIPLAS CONTAS (COM SUPORTE A GITHUB SYNC) =========
if [ "$MULTICONTA_ATIVO" != "1" ]; then
    while true; do
        clear
        echo "========================================"
        echo "  ⚔️ TITANS WAR - MÚLTIPLAS CONTAS ⚔️ "
        echo "========================================"
        echo " 1) 🚀 Cadastrar, Configurar e Iniciar Contas"
        
        NUM_PASTAS=$(ls -1d $HOME/twm_conta* 2>/dev/null | wc -l)
        if [ "$NUM_PASTAS" -gt 0 ]; then
            echo " 2) 🖥️  Painel de Monitoramento ao Vivo"
        fi
        
        echo " 99) 🗑️ Resetar Tudo   |   0) ❌ Sair"
        echo "========================================"
        read -p "Escolha uma opção: " OPCAO
        
        if [ "$OPCAO" = "1" ]; then
            read -p "Quantas contas deseja configurar/rodar? (ex: 2): " NUM_CONTAS
            if [ -n "$NUM_CONTAS" ] && [ "$NUM_CONTAS" -gt 0 ]; then
                for i in $(seq 1 $NUM_CONTAS); do
                    DIR_CONTA="$HOME/twm_conta$i"
                    mkdir -p "$DIR_CONTA"
                    
                    # Clona a base original mantendo a sincronização com o GitHub ativa
                    cp -r $HOME/twm/* "$DIR_CONTA/" 2>/dev/null
                    find "$DIR_CONTA" -type f -exec sed -i "s|$HOME/twm|$DIR_CONTA|g" {} + 2>/dev/null
                    find "$DIR_CONTA" -type f -exec sed -i "s|~/twm|$DIR_CONTA|g" {} + 2>/dev/null
                    
                    # Verifica se a conta já possui dados salvos
                    SALVO=$(find "$DIR_CONTA" -name "cript_file" 2>/dev/null | wc -l)
                    if [ "$SALVO" -eq 0 ]; then
                        echo "========================================"
                        echo "🔑 CONFIGURAÇÃO DA CONTA $i"
                        echo "========================================"
                        echo "Selecione o Servidor da Conta $i:"
                        echo " 1) English, Global"
                        echo " 2) Русский"
                        echo " 3) Polski"
                        echo " 4) Deutsch"
                        echo " 5) Español"
                        echo " 6) Brasil, Português (Furia de Titãs)"
                        echo " 7) Italiano"
                        echo " 8) Français"
                        echo " 9) Română"
                        echo "10) 中文, Chinese"
                        echo "11) Indonesian"
                        read -p "Digite o número do servidor (1 a 11): " SV
                        
                        if [ -z "$SV" ]; then SV="6"; fi
                        
                        # Salva o servidor no arquivo ur_file exclusivo da conta[span_0](start_span)[span_0](end_span)
                        echo "$SV" > "$DIR_CONTA/ur_file"
                        
                        read -p "Usuário da Conta $i: " USERNAME
                        # Removido o parâmetro -s para a senha aparecer visível
                        read -p "Senha da Conta $i (visível): " PASSWORD
                        echo ""
                        
                        # Cria o diretório do servidor correspondente e salva as credenciais criptografadas[span_1](start_span)[span_1](end_span)
                        mkdir -p "$DIR_CONTA/.$SV"
                        echo "login=$USERNAME&pass=$PASSWORD" | base64 -w 0 > "$DIR_CONTA/.$SV/cript_file"
                        chmod 600 "$DIR_CONTA/.$SV/cript_file"
                    else
                        echo "✅ CONTA $i - Dados de login já existentes carregados."
                    fi
                done
                
                echo "========================================"
                echo "🚀 Iniciando $NUM_CONTAS contas em segundo plano..."
                for i in $(seq 1 $NUM_CONTAS); do
                    DIR_CONTA="$HOME/twm_conta$i"
                    cd "$DIR_CONTA"
                    export MULTICONTA_ATIVO="1"
                    nohup ./play.sh $1 > "log_conta$i.txt" 2>&1 &
                done
                echo "✅ Contas ativas em segundo plano! Pressione ENTER para voltar ao menu."
                read
            fi
            
        elif [ "$OPCAO" = "2" ] && [ "$NUM_PASTAS" -gt 0 ]; then
            while true; do
                clear
                echo "================================================="
                echo "       📊 PAINEL DE MONITORAMENTO GERAL 📊       "
                echo "================================================="
                
                for i in $(seq 1 $NUM_PASTAS); do
                    DIR_CONTA="$HOME/twm_conta$i"
                    SV_ATUAL=$(cat "$DIR_CONTA/ur_file" 2>/dev/null || echo "6")[span_2](start_span)[span_2](end_span)
                    
                    STATUS=$(tail -n 10 "$DIR_CONTA/log_conta$i.txt" 2>/dev/null | grep -v "^$" | tail -n 1)
                    STATUS_LIMPO=$(echo "$STATUS" | sed -r 's/\x1B\[[0-9;]*[a-zA-Z]//g' | cut -c 1-40)
                    
                    MSG_FILE=$(find "$DIR_CONTA" -name "msg_file" 2>/dev/null | head -n 1)
                    if [ -f "$MSG_FILE" ]; then
                        HP_MP=$(grep "HP" "$MSG_FILE" | sed -r 's/\x1B\[[0-9;]*[a-zA-Z]//g')
                    else
                        HP_MP="Conectando e sincronizando..."
                    fi
                    
                    echo " 👤 CONTA $i (Servidor ID: $SV_ATUAL):"
                    echo "    $HP_MP"
                    echo "    📌 Status: $STATUS_LIMPO"
                    echo "-------------------------------------------------"
                done
                echo "Atualizando a cada 3 segundos... (Pressione CTRL+C para sair do painel)"
                sleep 3
            done
            
        elif [ "$OPCAO" = "99" ]; then
            echo "⚠️ Parando os bots e apagando os dados..."
            pkill -f "twm_conta" 2>/dev/null
            rm -rf $HOME/twm_conta*
            echo "✅ Sistema limpo com sucesso!"
            sleep 2
            
        elif [ "$OPCAO" = "0" ]; then
            exit 0
        else
            echo "Opção inválida!"
            sleep 1
        fi
    done
fi
# ========= FIM DA INTERFACE MULTICONTAS =========

(
 RUN=$1
 echo "$RUN" >$HOME/twm/runmode_file[span_3](start_span)[span_3](end_span)
 while true; do
  pidf=$(jobs -l | awk '/sh.*twm\/twm\.lib/ { if (NR == 1) print $2 }')
  until [ -z "${pidf}" ]; do
   kill -9 ${pidf} 2>/dev/null
   pidf=$(jobs -l | awk '/sh.*twm\/twm\.lib/ { if (NR == 1) print $2 }')
   sleep 1s
  done
  run_mode () {
   if echo "$RUN"|grep -q -E '[-]cl'; then
    chmod +x $HOME/twm/twm.sh ; $HOME/twm/twm.sh[span_4](start_span)[span_4](end_span)
   elif echo "$RUN"|grep -q -E '[-]cv'; then
    chmod +x $HOME/twm/twm.sh ; $HOME/twm/twm.sh -cv[span_5](start_span)[span_5](end_span)
   elif echo "$RUN"|grep -q -E '[-]boot'; then
    echo '-boot' >$HOME/twm/runmode_file ; chmod +x $HOME/twm/twm.sh ; $HOME/twm/twm.sh -boot[span_6](start_span)[span_6](end_span)
   else
    echo '-boot' >$HOME/twm/runmode_file ; chmod +x $HOME/twm/twm.sh ; $HOME/twm/twm.sh -boot[span_7](start_span)[span_7](end_span)
   fi
  }
  run_mode
  sleep 0.1s
 done
)
