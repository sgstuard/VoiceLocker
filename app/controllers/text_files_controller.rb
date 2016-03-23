class TextFilesController < ApplicationController

  def index
    @text_files = TextFile.all
  end

  def new
    @text_file = TextFile.new
  end

  def show
    @text_file = TextFile.find(params[:id])
  end

  def edit
    @text_file = TextFile.find(params[:id])
  end

  def create
  @text_file = TextFile.new(file_params)

    if @text_file.save
      redirect_to @text_file
    else
      render 'new'
    end

  end

  def update
    @text_file = TextFile.find(params[:id])

    if @text_file.update(file_params)
      redirect_to @text_file
    else
      render 'edit'
    end
  end

  def destroy
    @text_file = TextFile.find(params[:id])
    @text_file.destroy

    redirect_to text_files_path
  end

  private
  def file_params
    params.require(:text_file).permit(:title, :text)
  end

end
