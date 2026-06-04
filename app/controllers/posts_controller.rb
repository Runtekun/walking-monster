class PostsController < ApplicationController
    def index
        @posts = Post.includes(:user).all.page(params[:page]).per(25)
    end

    def new
        @post= Post.new
    end

    def create
        @post = current_user.posts.build(post_params)
        if @post.save
          flash[:notice] = "投稿が作成されました"
          redirect_to posts_path
        else
          flash.now[:alert] = "投稿に失敗しました"
          render :new, status: :unprocessable_entity
        end
    end

    def show
      @post = Post.find(params[:id])
      @comment = Comment.new
      @comments = @post.comments.includes(:user).order(created_at: :desc)
    end

    def edit
      @post = current_user.posts.find(params[:id])
    end

    def update
      @post = current_user.posts.find(params[:id])
      if @post.update(post_params)
        redirect_to post_path(@post), success: "投稿を更新しました。"
      else
        flash.now[:danger] = "投稿の更新に失敗しました。"
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      post = current_user.posts.find(params[:id])
      post.destroy!
      redirect_to posts_path, success: "投稿を削除しました。", status: :see_other
    end


    private

  def post_params
    params.require(:post).permit(:title, :body, :post_image)
  end
end
