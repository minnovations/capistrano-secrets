namespace :deploy do
  desc 'Create basic directory structure'
  task :create_directories do
    on roles(:app) do |host|
      sudo :mkdir, '-p', releases_path, shared_path
      sudo :chown, '-R', "#{host.user}:$(id -gn #{host.user})", fetch(:deploy_to)
      execute :chmod, 'g+rws', fetch(:deploy_to), releases_path, shared_path
    end
  end

  desc 'Upload dotenv'
  task upload_dotenv: [:create_directories] do
    dotenv_file_local = fetch(:dotenv_file_local, "./secrets/.env.#{fetch(:stage)}")
    dotenv_file_remote = fetch(:dotenv_file_remote, "#{shared_path}/.env")

    on roles(:app) do
      execute :mkdir, '-p', File.dirname(dotenv_file_remote)
      upload! dotenv_file_local, dotenv_file_remote
      execute :chmod, 'o-rwx', dotenv_file_remote
    end
  end

  desc 'Upload secrets'
  task upload_secrets: [:create_directories] do
    secrets_dir_local = fetch(:secrets_dir_local, './secrets')
    secrets_dir_remote = fetch(:secrets_dir_remote, "#{shared_path}/secrets")

    on roles(:app) do
      execute :mkdir, '-p', File.dirname(secrets_dir_remote)
      upload! secrets_dir_local, secrets_dir_remote, recursive: true
      execute :chmod, '-R', 'o-rwx', secrets_dir_remote
    end
  end
end
