# ------------------------------
# PHP セットアップ
# ------------------------------
echo "=== PHP セットアップ開始 ==="
export REGION=ap-northeast-1


# ディレクトリ作成
mkdir -p /mnt/c/ci_cd_aws_seminar_php
cd /mnt/c/ci_cd_aws_seminar_php

# GitHub 初期化
echo "# ci_cd_aws_seminar_php" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin git@github.com:youri0326/ci_cd_aws_seminar_php.git
git push -u origin main

# ------------------------------
# 改行コードのLFに固定
# ------------------------------
sudo apt update
sudo apt install dos2unix

dos2unix /mnt/c/cicd_aws_seminar/php-cicd/CodeDeploy/appspec.yml

# ------------------------------
# 既存ファイルをコピー
# ------------------------------
cp -r /mnt/c/cicd_aws_seminar/php-cicd/* /mnt/c/ci_cd_aws_seminar_php

# ------------------------------
# ファイルをGitにコミット・プッシュ
# ------------------------------
git add .
git commit -m "Add initial project files for CI/CD setup"
git push origin main


# CodeBuild プロジェクト作成
aws codebuild create-project \
  --name php-build-yoshiike-20251019 \
  --source type=CODEPIPELINE,buildspec=CodeBuild/buildspec-php.yml \
  --artifacts type=CODEPIPELINE \
  --environment type=LINUX_CONTAINER,computeType=BUILD_GENERAL1_SMALL,image=aws/codebuild/standard:5.0 \
  --service-role arn:aws:iam::963220189927:role/CodeBuildServiceRole-yoshiike-20251019 \
  --region ${REGION}

# CodeDeploy アプリ作成
aws deploy create-application \
  --application-name cicd-aws-codedeploy-php-yoshiike-20251019 \
  --compute-platform ECS \
  --region ${REGION}

# CodeDeploy デプロイグループ作成
# aws deploy create-deployment-group \
#   --application-name cicd-aws-codedeploy-php-yoshiike-20251019 \
#   --deployment-group-name cicd-aws-codedeploy-php-group \
#   --service-role-arn arn:aws:iam::963220189927:role/CodeDeployServiceRole-yoshiike-20251019 \
#   --deployment-style deploymentType=BLUE_GREEN,deploymentOption=WITH_TRAFFIC_CONTROL \
#   --target-group-pair-info file://CodeDeploy/tg-pair.json \
#   --ecs-services clusterName=ecs-cluster-yoshiike-20251019,serviceName=php-service-yoshiike-20251019 \
#   --region ${REGION}

aws deploy create-deployment-group \
  --cli-input-json file://CodeDeploy/tg-pair.json \
  --region ap-northeast-1

# CodePipeline 作成（Blue/Green）
aws codepipeline create-pipeline \
  --cli-input-json file://CodePipeline/pipeline-php-bluegreen.json \
  --region ${REGION}

echo "=== すべてのセットアップが完了しました ==="

aws deploy create-deployment-group   --cli-input-json file://CodeDeploy/tg-pair.json   --region ap-northeast-1

aws codebuild delete-project \
  --name php-build-yoshiike-20251019 \
  --region ${REGION}

aws deploy delete-application \
  --application-name cicd-aws-codedeploy-php-yoshiike-20251019 \
  --region ${REGION}
