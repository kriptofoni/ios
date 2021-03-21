package aegean.dev.mobilfinal.adapters;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import java.io.Serializable;
import java.util.ArrayList;

import aegean.dev.mobilfinal.Cards.Reminder;
import aegean.dev.mobilfinal.MainActivity;
import aegean.dev.mobilfinal.R;
import aegean.dev.mobilfinal.ReminderInfoActivity;

public class RecyclerViewAdapter extends RecyclerView.Adapter<RecyclerViewAdapter.Holder> {

    private ArrayList<Reminder> reminders;
    private MainActivity mainActivity;

    public RecyclerViewAdapter(ArrayList<Reminder> reminders, MainActivity mainActivity) {
        this.reminders = reminders;
        this.mainActivity = mainActivity;
    }

    @NonNull
    @Override
    public Holder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        LayoutInflater layoutInflater = LayoutInflater.from(parent.getContext());
        View view = layoutInflater.inflate(R.layout.recycler_view_row, null);
        return new Holder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull Holder holder, final int position) {
        holder.title.setText(reminders.get(position).getTitle());
        holder.detail.setText(reminders.get(position).getDetail());
        holder.completed.setText(reminders.get(position).isCompleted() ? "Tamamlandı" : "Tamamlanmadı");
        String idText = reminders.get(position).getId() + "-";
        holder.id.setText(idText);
        holder.recyclerRow.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(mainActivity, ReminderInfoActivity.class);
                intent.putExtra("reminders", reminders);
                intent.putExtra("position", position);
                mainActivity.startActivityForResult(intent, 0);
            }
        });
    }

    @Override
    public int getItemCount() {
        return reminders.size();
    }

    public class Holder extends RecyclerView.ViewHolder {

        TextView title, detail, completed, id;
        RelativeLayout recyclerRow;

        public Holder(@NonNull View itemView) {
            super(itemView);

            title = itemView.findViewById(R.id.recycler_title);
            detail = itemView.findViewById(R.id.recycler_detail);
            completed = itemView.findViewById(R.id.recycler_completed);
            id = itemView.findViewById(R.id.recycler_id);
            recyclerRow = itemView.findViewById(R.id.recycler_row);
        }
    }
}
