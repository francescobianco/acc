
main() {

  if [ -f ".env" ]; then
      set -o allexport
      source .env
      set +o allexport
  fi

  local file_pattern

  file_pattern=$1

  # Verifica se il file di sessione esiste
  #if [ -e ".openai_session" ]; then
  #    read -p "Vuoi usare la sessione precedente? (sì/no): " use_previous_session
  #    if [ "$use_previous_session" == "no" ]; then
  #        rm -f ".openai_session"
  #    fi
  #fi

  # Inizia o riprende la sessione
  #openai session create

  # Chiede all'utente cosa fare
  #read -p "Cosa vuoi che faccia? (Esempio: Controlla se ci sono parole spagnole): " action

  action="traduci i commenti in inglese"

  echo "Apply thi action '${action}' to the following files:" > prompt.txt
  for file in $file_pattern; do
      # shellcheck disable=SC2129
      echo "--- Begin file: $file ---" >> prompt.txt
      cat "$file" >> prompt.txt
      echo "--- End file: $file ---" >> prompt.txt
  done

  # Esegue l'azione con OpenAI API
  #openai api completions.create --model text-davinci-002 --prompt "$(cat prompt.txt)" > response.json

  prompt=$(cat prompt.txt)

  openai api chat_completions.create \
      --model 'gpt-3.5-turbo'         \
      --message user "$prompt"        \
      --temperature 0                 \
      --stop '<STOP>'                 \
      --max-tokens 500 > response.txt

  # Estrae i nomi dei file modificati dal JSON di risposta
  #modified_files=$(jq -r '.choices[].file' response.json)

  # Crea la versione precedente dei file modificati
  for file in $modified_files; do
      timestamp=$(date +"%Y%m%d%H%M%S")
      cp "$file" "${file}_rev${timestamp}"
  done

  # Scarica i file aggiornati
  #openai api files.download --files "$modified_files" --dest .

  echo "Operazione completata. I file aggiornati sono stati scaricati e le versioni precedenti sono state create."
}
