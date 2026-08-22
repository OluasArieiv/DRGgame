#!/bin/bash

# Copyright (c) 2019-2024 Ueliton Alves Dos Santos
# Licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License

# ========= INÍCIO DA INTERFACE MULTICONTAS =========
if [ "$MULTICONTA_ATIVO" != "1" ]; then
    while true; do
        clear
        echo "========================================"
        echo "  ⚔️ TITANS WAR - MÚLTIPLAS CONTAS ⚔️ "
        echo "========================================"
        echo " 1) 🚀 Cadastrar e Iniciar Contas"
        
        NUM_PASTAS=$(ls -1d $HOME/twm_conta* 2>/dev/null | wc -l)
        if [ "$NUM_PASTAS" -gt 0 ]; then
            echo " 2) 🖥️  Painel de Monitoramento (Ao Vivo)"
        fi
        
        echo " 99) 🗑️ Resetar Tudo   |   0) ❌ Sair"
        echo "========================================"
        read -p "Escolha uma opção: " OPCAO
        
        if [ "$OPCAO" = "1" ]; then
            read -p "Quantas contas deseja rodar? (ex: 2): " NUM_CONTAS
            if [ -n "$NUM_CONTAS" ] && [ "$NUM_CONTAS" -gt 0 ]; then
                for i in $(seq 1 $NUM_CONTAS); do
                    DIR_CONTA="$HOME/twm_conta$i"
                    mkdir -p "$DIR_CONTA"
                    
                    # Prepara a pasta isolada e desativa as atualizações automáticas
                    cp -r $HOME/twm/* "$DIR_CONTA/" 2>/dev/null
                    find "$DIR_CONTA" -type f -exec sed -i "s|$HOME/twm|$DIR_CONTA|g" {} + 2>/dev/null
                    find "$DIR_CONTA" -type f -exec sed -i "s|~/twm|$DIR_CONTA|g" {} + 2>/dev/null
                    sed -i 's/sync_func/#sync_func/g' "$DIR_CONTA/twm.sh" 2>/dev/null
                    sed -i 's/sync_func_other/#sync_func_other/g' "$DIR_CONTA/twm.sh" 2>/dev/null
                    
                    # Verifica login
                    SALVO=$(find "$DIR_CONTA" -name "cript_file" 2>/dev/null | wc -l)
                    if [ "$SALVO" -eq 0 ]; then
                        echo "🔑 CONTA $i - CADASTRO"
                        read -p "Usuário: " USERNAME
                        read -s -p "Senha: " PASSWORD
                        echo ""
                        SV=$(cat "$DIR_CONTA/ur_file" 2>/dev/null || echo "6")
                        mkdir -p "$DIR_CONTA/.$SV"
                        echo "login=$USERNAME&pass=$PASSWORD" | base64 -w 0 > "$DIR_CONTA/.$SV/cript_file"
                        chmod 600 "$DIR_CONTA/.$SV/cript_file"
                    fi
                done
                
                echo "🚀 Iniciando $NUM_CONTAS contas em segundo plano..."
                for i in $(seq 1 $NUM_CONTAS); do
                    DIR_CONTA="$HOME/twm_conta$i"
                    cd "$DIR_CONTA"
                    export MULTICONTA_ATIVO="1"
                    # Salva o texto que passaria na tela em um arquivo log_conta.txt
                    nohup ./play.sh $1 > "log_conta$i.txt" 2>&1 &
                done
                echo "✅ Contas rodando! Pressione ENTER para voltar ao menu e escolha a Opção 2 para monitorar."
                read
            fi
            
        elif [ "$OPCAO" = "2" ] && [ "$NUM_PASTAS" -gt 0 ]; then
            # --- TELA DE PAINEL DE MONITORAMENTO ---
            while true; do
                clear
                echo "================================================="
                echo "       📊 PAINEL DE MONITORAMENTO GERAL 📊       "
                echo "================================================="
                
                for i in $(seq 1 $NUM_PASTAS); do
                    DIR_CONTA="$HOME/twm_conta$i"
                    
                    # Pega a última ação do bot direto do arquivo de log
                    STATUS=$(tail -n 10 "$DIR_CONTA/log_conta$i.txt" 2>/dev/null | grep -v "^$" | tail -n 1)
                    STATUS_LIMPO=$(echo "$STATUS" | sed -r 's/\x1B\[[0-9;]*[a-zA-Z]//g' | cut -c 1-50)
                    
                    # Pega o HP e MP
                    MSG_FILE=$(find "$DIR_CONTA" -name "msg_file" 2>/dev/null | head -n 1)
                    if [ -f "$MSG_FILE" ]; then
                        HP_MP=$(grep "HP" "$MSG_FILE" | sed -r 's/\x1B\[[0-9;]*[a-zA-Z]//g')
                    else
                        HP_MP="Aguardando conexão com o servidor..."
                    fi
                    
                    echo " 👤 CONTA $i:"
                    echo "    $HP_MP"
                    echo "    📌 Status Atual: $STATUS_LIMPO"
                    echo "-------------------------------------------------"
                done
                echo "Atualizando a cada 3 segundos... (Pressione CTRL+C para sair do painel)"
                sleep 3
            done
            
        elif [ "$OPCAO" = "99" ]; then
            echo "⚠️ Apagando contas e parando os bots..."
            # Encerra apenas os processos das contas clonadas
            pkill -f "twm_conta" 2>/dev/null
            rm -rf $HOME/twm_conta*
            echo "✅ Dados resetados com sucesso!"
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
 echo "$RUN" >$HOME/twm/runmode_file
 while true; do
  pidf=$(jobs -l | awk '/sh.*twm\/twm\.lib/ { if (NR == 1) print $2 }')
  until [ -z "${pidf}" ]; do
   kill -9 ${pidf} 2>/dev/null
   pidf=$(jobs -l | awk '/sh.*twm\/twm\.lib/ { if (NR == 1) print $2 }')
   sleep 1s
  done
  run_mode () {
   if echo "$RUN"|grep -q -E '[-]cl'; then
    chmod +x $HOME/twm/twm.sh ; $HOME/twm/twm.sh
   elif echo "$RUN"|grep -q -E '[-]cv'; then
    chmod +x $HOME/twm/twm.sh ; $HOME/twm/twm.sh -cv
   elif echo "$RUN"|grep -q -E '[-]boot'; then
    echo '-boot' >$HOME/twm/runmode_file ; chmod +x $HOME/twm/twm.sh ; $HOME/twm/twm.sh -boot
   else
    echo '-boot' >$HOME/twm/runmode_file ; chmod +x $HOME/twm/twm.sh ; $HOME/twm/twm.sh -boot
   fi
  }
  run_mode
  sleep 0.1s
 done
)
