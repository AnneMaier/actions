#!/bin/bash

# NVM 환경 로드 (스크립트 시작 부분에 유지)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# NVM을 사용하여 Node.js 버전 활성화 (예: 최신 LTS 또는 특정 버전)
nvm use node || nvm install node && nvm use node # node 버전이 없으면 설치 후 사용

# 원격 서버의 Git 리포지토리 경로 지정 (이 스크립트가 배포할 프로젝트의 실제 Git 저장소)
# 현재 스크립트 로직상 /work/actions/nodejs/hello 에 소스가 있고
# 그 소스를 복사해서 배포하는 형태인데, Git Pull 은 다른 디렉토리에서 하고 있음
# 이 부분의 의도를 명확히 해야 합니다.

# 만약 원격 서버의 /work/actions/nodejs/hello 가 Git Repo라면
# PROJECT_REPO_DIR="/work/actions/nodejs/hello"
# cd "$PROJECT_REPO_DIR" && git pull

# 그러나 현재 스크립트의 의도는 /work/actions/nodejs/hello 에 있는 소스를 복사하는 것 같으므로,
# git pull 부분은 제거하거나, 이 스크립트가 관리하는 리포지토리 경로로 수정해야 합니다.

# 예시: 만약 /root/actions/your-app-repo 가 배포할 Git 리포토리이고 그 안에 deploy.sh 가 있다면
# PROJECT_DIR="$HOME/actions/your-app-repo"
# if [ -d "$PROJECT_DIR" ]; then
#   cd "$PROJECT_DIR"
#   git pull
# else
#   echo "Error: Project directory $PROJECT_DIR does not exist. Please clone it first."
#   exit 1
# fi


# 현재 스크립트의 원래 의도를 최대한 살린 수정 (SRC 경로 존재 시)
SRC="/work/actions/nodejs/hello" # 이 경로가 원격 서버에 실제로 존재해야 함
DEST="$HOME/deploy" # /root/deploy 또는 /home/<user>/deploy

echo "INFO: Removing old deployment directory: $DEST"
rm -rf "$DEST"

echo "INFO: Creating new deployment directory: $DEST"
mkdir -p "$DEST"

echo "INFO: Copying source from $SRC to $DEST"
# cp -r $SRC $DEST 는 /DEST/hello 로 복사됨
# 만약 /DEST 에 바로 복사하고 싶다면 cp -r $SRC/. $DEST 또는 rsync -av $SRC/ $DEST
cp -r "$SRC" "$DEST" # 현재 스크립트대로 하면 $DEST/hello 가 됩니다.

# 복사된 프로젝트 디렉토리로 이동
PROJECT_APP_DIR="$DEST/hello" # cp -r $SRC $DEST 때문에 생기는 경로
echo "INFO: Changing directory to $PROJECT_APP_DIR"
if [ -d "$PROJECT_APP_DIR" ]; then
  cd "$PROJECT_APP_DIR"
else
  echo "Error: Copied project directory $PROJECT_APP_DIR does not exist."
  exit 1 # 스크립트 강제 종료
fi

# .bashrc 소스는 보통 필요하지 않거나, NVM 로드와 중복될 수 있습니다.
# 필요한 경우에만 유지하고, 아니면 제거하는 것을 고려하세요.
# source ~/.bashrc

echo "INFO: Running npm install..."
npm install

# npm install이 성공적으로 완료되었는지 확인
if [ $? -ne 0 ]; then
  echo "Error: npm install failed. Exiting deployment."
  exit 1 # npm install 실패 시 스크립트 강제 종료
fi

echo "INFO: Restarting PM2 applications..."
pm2 restart all

echo "Deployment script finished."