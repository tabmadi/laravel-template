<!doctype html>
<html lang="en">

<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Notes</title>
</head>

<body>
  <main>
    <h1>Notes</h1>
    <form action="{{ route('notes.store') }}" method="post">
      @csrf
      <label for="body">Note</label>
      <textarea id="body" name="body" rows="3" maxlength="240" required>{{ old('body') }}</textarea>
      @error('body')
        <p role="alert">{{ $message }}</p>
      @enderror
      <button type="submit">Save note</button>
    </form>
    @if ($notes->isEmpty())
      <p>No notes yet.</p>
    @else
      <ul>
        @foreach ($notes as $note)
          <li>{{ $note->body }}</li>
        @endforeach
      </ul>
      <nav aria-label="Notes pages">
        @if ($notes->previousPageUrl())
          <a href="{{ $notes->previousPageUrl() }}">Previous</a>
        @endif
        @if ($notes->nextPageUrl())
          <a href="{{ $notes->nextPageUrl() }}">Next</a>
        @endif
      </nav>
    @endif
  </main>
</body>

</html>
