
 ---secret token is only needed when we are cloning private repo----
create or replace secret my_github_secret
type = password
username = 'kanak##'
password=''--- write your PAT since it will expire in 1 day 

show secrets;


create or replace api integration Integration_to_KanakGitHub
    api_provider = git_https_api
    api_allowed_prefixes = ('account name here')
    enabled = true
    allowed_authentication_secrets = (my_github_secret)
    -- comment='<comment>';

show api integrations;
show integrations;

Create or replace git repository kanak_github_repo
api_integration= Integration_to_KanakGitHub
git_credentials= my_github_secret
origin='<your acount name>/DataIngestionUsingSnowflakeTask'


alter git repository kanak_github_repo fetch;

ls @kanak_github_repo/branches/main;



