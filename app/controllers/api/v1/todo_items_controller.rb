class Api::V1::TodoItemsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_todo_item, only: [:show, :edit, :update, :destroy]
    def index
        @todo_items = current_user.todo_items.all
    end
    def show
        if authorized?
            respond_to do |format|
                format.json { render :show }
            end
        else
            check_unauthorized
        end
    end
    def create
        @todo_item = current_user.todo_items.build(todo_item_params)
        if authorized?
          respond_to do |format|
            if @todo_item.save
              format.json { render :show, status: :created, location: api_v1_todo_item_path(@todo_item) }
            else
              format.json { render json: @todo_item.errors, status: :unprocessable_entity }
            end
          end
        else
          check_unauthorized
        end
    end
    def update
      if authorized?
        respond_to do |format|
          if @todo_item.update(todo_item_params)
            format.json { render :show, status: :ok, location: api_v1_todo_item_path(@todo_item) }
          else
            format.json { render json: @todo_item.errors, status: :unprocessable_entity }
          end
        end
      else
        check_unauthorized
      end
    end
    def destroy
      if authorized?
        @todo_item.destroy
        respond_to do |format|
          format.json { head :no_content }
        end
      else
        check_unauthorized
      end
    end
    private
        def set_todo_item
            @todo_item = TodoItem.find(params[:id])
        end
        def authorized?
            @todo_item.user_id == current_user.id
        end
        def check_unauthorized
            if !authorized?
              respond_to do |format|
                format.json { render :unauthorized, status: 401 }
              end
            end
        end
        def todo_item_params
            params.require(:todo_item).permit(:title, :deadline, :complete)
        end
end
