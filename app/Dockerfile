FROM php:8.1-apache

# 必要なPHP拡張をインストール
RUN docker-php-ext-install mysqli pdo pdo_mysql

# 作業ディレクトリを設定（相対パスを簡略化）
WORKDIR /var/www/html

# プロジェクト全体をコピー
COPY . /var/www/html/

# 権限調整（任意：ファイルアップロードや書き込みをするなら必要）
RUN chown -R www-data:www-data /var/www/html

