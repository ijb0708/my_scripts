#!/bin/sh

SHELL_PATH=`pwd -P`

fromPolder=${1}
toPolder=${2}

if [ -z $fromPolder ] || [ -z $toPolder ] ; 
then
    echo "인자값을 3개(비교해서 보낼 폴더의 경로, 받을 경로) 넣어주세요"
    exit 100
fi

echo "보낼 폴더 : "${fromPolder}
echo "받을 폴더 : "${toPolder}

echo "현재 경로는  $SHELL_PATH 입니다."


compare_space=${SHELL_PATH}/${fromPolder}_compare_spcace
from_space=${SHELL_PATH}/${fromPolder}
temp_space=${compare_space}/temp

# 첫 번째 인자: 원본 디렉토리 경로
# 두 번째 인자: 대상 디렉토리 경로
# 세 번째 인자: 변경된 파일 리스트
copy_files() {
    from_dir="$1"
    to_dir="$2"
    file_list="$3"

    for file in "${file_list[@]}"; do
        # 절대 경로를 상대 경로로 변환
        rel_path="${file#$from_dir/}"
        # 복사 대상 디렉토리에 존재하지 않는 하위 디렉토리가 있다면 생성
        mkdir -p "$to_dir/$(dirname "$rel_path")"
        # 파일 복사
        
        echo "copy "${from_space}/$file" to "$to_dir/$rel_path"."

        cp "${from_space}/$file" "$to_dir/$rel_path"
    done
}

if [ ! -e ${compare_space} ]; 
then
    echo "현재경로에서 비교를 위한 ${fromPolder}_compare_space 폴더가 생성합니다 ..."
    mkdir ${fromPolder}_compare_spcace

fi

if [ ! -e ${compare_space}/temp ]; 
then
    echo "현재경로에서 비교를 위한 ${fromPolder}_compare_space/temp 폴더가 생성합니다 ..."
    mkdir ${compare_space}/temp

fi

echo "파일을 비교합니다..."

echo "변경사항 저장 폴더 경로 "${temp_space}

rsync -az --checksum --out-format="%n" ${from_space}/ ${temp_space} > ${compare_space}/file_list.txt

echo "변경된 파일 리스트 "${compare_space}"/file_list.txt 으로 생성"

# 파일 리스트를 읽어들임
if [ -s ${compare_space}/file_list.txt ]; then
  IFS=$'\n' read -d '' -ra files < ${compare_space}/file_list.txt
else
  echo "수정된 내용이 없습니다."
  exit 200
fi

echo "복사시작"

copy_files ${from_space} ${toPolder} "${files[@]}"

echo "완료 . . ."