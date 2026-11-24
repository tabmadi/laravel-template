<?php

declare(strict_types=1);

namespace App\Http\Controllers;

use App\Http\Requests\StoreNoteRequest;
use App\Models\Note;
use Illuminate\Contracts\View\View;
use Illuminate\Http\RedirectResponse;

final class NoteController
{
    public function index(): View
    {
        return view('notes', [
            'notes' => Note::query()->latest('id')->simplePaginate(20),
        ]);
    }

    public function store(StoreNoteRequest $request): RedirectResponse
    {
        Note::query()->create($request->validated());

        return to_route('notes.index');
    }
}
