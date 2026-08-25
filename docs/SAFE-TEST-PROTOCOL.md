# Protocolo seguro de instalação e teste

Este protocolo separa instalação, ativação do driver e conexão Wi-Fi. O
adaptador deve permanecer desconectado até a etapa indicada.

## 1. Antes da instalação

- manter uma conexão de rede alternativa funcionando;
- deixar o adaptador AIC8800D80 desconectado;
- confirmar que não há outro pacote ou instalação manual do AIC8800;
- executar `aic8800d80-check` quando o comando já estiver disponível;
- registrar o kernel em execução e confirmar seus headers.

## 2. Instalar o pacote

Usar o gerenciador de pacotes, para que dependências e remoção sejam
rastreáveis:

```sh
sudo apt install ./aic8800d80-recovery-dkms_1.0.0-2_all.deb
```

O pacote compila e instala os módulos no disco, mas não executa `modprobe` e não
descarrega nenhum módulo existente.

## 3. Validar antes de conectar

```sh
aic8800d80-check
dkms status
modinfo -n aic_load_fw
modinfo -n aic8800_fdrv
```

Os dois módulos devem estar instalados para o kernel em execução e o `vermagic`
deve começar pelo valor retornado por `uname -r`.

## 4. Reiniciar ainda sem o adaptador

Reiniciar evita trocar módulos durante uma sessão de rede ativa. Depois do boot,
confirmar primeiro que a conexão alternativa continua funcionando e repetir
`aic8800d80-check`.

## 5. Conectar o adaptador

Somente após as etapas anteriores:

1. iniciar captura dos eventos do kernel;
2. conectar o adaptador;
3. registrar os IDs USB em cada etapa da troca de modo;
4. confirmar que surge uma nova interface de rede;
5. não remover nem substituir a conexão de rede alternativa.

Não executar comandos de gravação de flash durante esse teste.

## 6. Testar Wi-Fi

Conectar a nova interface a uma rede de teste sem apagar perfis existentes.
Validar descoberta de redes, autenticação, obtenção de endereço, tráfego e uma
reconexão após retirar e recolocar o adaptador.

## 7. Remoção

Se a instalação precisar ser revertida:

```sh
sudo apt remove --purge aic8800d80-recovery-dkms
sudo reboot
```

O reboot garante que nenhum módulo previamente carregado permaneça apenas na
memória depois que seus arquivos forem removidos do disco.

## Evidência de validação: kernel 7.0

Teste realizado em 2026-08-25 no Linux Mint 22.3 XFCE, kernel
`7.0.0-30-generic`, com o pacote `aic8800d80-recovery-dkms_1.0.0-2_all.deb`:

- DKMS compilou e instalou os dois módulos para o kernel em execução;
- o adaptador iniciou como armazenamento `a69c:5721` (`Aic MSC`);
- a regra de troca de modo o apresentou como `a69c:8d80` (`AIC Wlan`);
- após a carga do firmware, o dispositivo final surgiu como `368b:8d81`
  (`AICSemi AIC 8800D80`);
- `aic_load_fw`, `aic8800_fdrv`, `cfg80211`, `btusb` e `bluetooth` ficaram
  carregados;
- Wi-Fi e Bluetooth apareceram desbloqueados, sem alerta persistente do kernel;
- o Wi-Fi autenticou em uma rede de 5 GHz e recebeu endereços IPv4 e IPv6;
- cinco respostas do gateway e 35 respostas da internet foram recebidas pela
  interface Wi-Fi, todas com 0% de perda, mantendo Ethernet como contingência.
- depois de retirar e recolocar fisicamente o adaptador, a troca de modo e a
  conexão de 5 GHz ocorreram novamente de forma automática; mais dez respostas
  da internet foram recebidas pela interface Wi-Fi com 0% de perda.

Este resultado eleva o kernel `7.0.0-30-generic` ao nível `WIFI_CONNECTS`. A
classificação `STABLE` ainda exige uso prolongado, reconexão e repetição após
atualizações de kernel.
